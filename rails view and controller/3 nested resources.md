!SLIDE title-slide

# nested resources #

!SLIDE incremental

# card belongs_to board

* one model belongs to another, and is dependent
* `has_many :cards, :dependent => :destroy`
* makes sense to nest urls:
* /boards/3/cards  - all the cards in board 3

!SLIDE smaller

# routes file:

    @@@ 
    resources :boards do
      resources :cards
    end

!SLIDE smaller

# Routes constructed by nested resources

    @@@ 
    GET    /boards                          
    POST   /boards                          
    GET    /boards/new                      
    GET    /boards/:id/edit                 
    GET    /boards/:id                      
    PUT    /boards/:id                      
    DELETE /boards/:id                      
    GET    /boards/:board_id/cards          
    POST   /boards/:board_id/cards          
    GET    /boards/:board_id/cards/new      
    GET    /boards/:board_id/cards/:id/edit 
    GET    /boards/:board_id/cards/:id      
    PUT    /boards/:board_id/cards/:id      
    DELETE /boards/:board_id/cards/:id      
