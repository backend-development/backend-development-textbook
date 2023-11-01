# frozen_string_literal: true

require "redcarpet"
require "nokogiri"
require "rails_guides/markdown/renderer"
require "rails-html-sanitizer"

module RailsGuides
  class Markdown
    def initialize(view:, layout:, edge:, version:, output_path:)
      @view          = view
      @layout        = layout
      @edge          = edge
      @version       = version
      @output_path   = output_path
      @index_counter = Hash.new(0)
      @raw_header    = ""
      @node_ids      = {}
    end

    def render(body)
      @raw_body = body
      extract_raw_header_and_body
      generate_header
      generate_description
      generate_title
      generate_body
      generate_structure
      generate_index
      render_page
    end

    private
      def dom_id(nodes)
        dom_id = dom_id_text(nodes.last.text)

        # Fix duplicate node by prefix with its parent node
        if @node_ids[dom_id]
          if @node_ids[dom_id].size > 1
            duplicate_nodes = @node_ids.delete(dom_id)
            new_node_id = "#{duplicate_nodes[-2][:id]}-#{duplicate_nodes.last[:id]}"
            duplicate_nodes.last[:id] = new_node_id
            @node_ids[new_node_id] = duplicate_nodes
          end

          dom_id = "#{nodes[-2][:id]}-#{dom_id}"
        end

        @node_ids[dom_id] = nodes
        dom_id
      end

      def dom_id_text(text)
        escaped_chars = Regexp.escape('\\/`*_{}[]()#+-.!:,;|&<>^~=\'"')

        text.downcase.gsub(/\?/, "-questionmark")
                     .gsub(/!/, "-bang")
                     .gsub(/[#{escaped_chars}]+/, " ").strip
                     .gsub(/\s+/, "-")
      end

      def engine
        @engine ||= Redcarpet::Markdown.new(Renderer,
          no_intra_emphasis: true,
          fenced_code_blocks: true,
          autolink: true,
          strikethrough: true,
          superscript: true,
          tables: true
        )
      end

      def extract_raw_header_and_body
        if /^-{40,}$/.match?(@raw_body)
          @raw_header, _, @raw_body = @raw_body.partition(/^-{40,}$/).map(&:strip)
        else
          puts "ERROR - add ad header that ends with 40 dashes on a line!"
        end
      end

      def generate_body
        @body = engine.render(@raw_body)
      end

      def generate_header
        @header = engine.render(@raw_header).gsub('<ul>', '<ul class="checkmark">').html_safe
      end

      def generate_description
        sanitizer = Rails::Html::FullSanitizer.new
        @description = sanitizer.sanitize(@header).squish
      end

      def generate_structure
        @headings_for_index = []
        if @body.present?
          @body = Nokogiri::HTML.fragment(@body).tap do |doc|
            hierarchy = []

            doc.children.each do |node|
              if /^h[3-6]$/.match?(node.name)
                case node.name
                when "h3"
                  hierarchy = [node]
                  @headings_for_index << [1, node, node.inner_html]
                when "h4"
                  hierarchy = hierarchy[0, 1] + [node]
                  @headings_for_index << [2, node, node.inner_html]
                when "h5"
                  hierarchy = hierarchy[0, 2] + [node]
                when "h6"
                  hierarchy = hierarchy[0, 3] + [node]
                end

                node[:id] = dom_id(hierarchy) unless node[:id]
                node.inner_html = "#{node_index(hierarchy)} #{node.inner_html}"
              end
            end

            doc.css("h3, h4, h5, h6").each do |node|
              node.inner_html = "<a class='anchorlink' href='##{node[:id]}'></a>#{node.inner_html}"
            end
          end.to_html
        end
      end

      def generate_index
        if @headings_for_index.present?
          raw_index = ""
          @headings_for_index.each do |level, node, label|
            if level == 1
              raw_index += "1. [#{label}](##{node[:id]})\n"
            elsif level == 2
              raw_index += "    * [#{label}](##{node[:id]})\n"
            end
          end

          @index = Nokogiri::HTML.fragment(engine.render(raw_index)).tap do |doc|
            doc.at("ol")[:class] = "chapters"
          end.to_html

          @index = <<-INDEX.html_safe
          <div id="subCol">
            <h3 class="chapter"><img src="images/chapters_icon.gif" alt="" />Chapters</h3>
            #{@index}
          </div>
          INDEX
        end
      end

      def generate_title
        if heading = Nokogiri::HTML.fragment(@header).at(:h2)
          @title = "#{heading.text} — Backend Development"
        else
          @title = "Backend Development Textbook"
        end
      end

      def node_index(hierarchy)
        case hierarchy.size
        when 1
          @index_counter[2] = @index_counter[3] = @index_counter[4] = 0
          "#{@index_counter[1] += 1}"
        when 2
          @index_counter[3] = @index_counter[4] = 0
          "#{@index_counter[1]}.#{@index_counter[2] += 1}"
        when 3
          @index_counter[4] = 0
          "#{@index_counter[1]}.#{@index_counter[2]}.#{@index_counter[3] += 1}"
        when 4
          "#{@index_counter[1]}.#{@index_counter[2]}.#{@index_counter[3]}.#{@index_counter[4] += 1}"
        end
      end

      def render_page
        @view.content_for(:source_file) { @source_file  }
        @view.content_for(:output_path) { @output_path  }
        if heading = Nokogiri::HTML(@header).at(:h2) then
          @view.content_for(:header_h2_section) { heading.text.html_safe }
          @view.content_for(:header_section) { @header }
        else
          @view.content_for(:header_h2_section) { "no heading" }
          @view.content_for(:header_section) { @header }
        end
        @view.content_for(:page_title) { @title }
        @view.content_for(:index_section) { @index }
        @view.render(layout: @layout, html: @body.html_safe)
      end
  end
end
