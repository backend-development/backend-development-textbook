node:
https://blog.logrocket.com/you-dont-need-babel-with-node/


advanced testing:
https://andycroll.com/ruby/replace-timecop-with-rails-time-helpers-in-rspec/

ruby-graphql
https://nordicapis.com/5-api-design-trends-to-look-out-for-in-2019/
graphql-errors
graphql-batch gegen n+1, record loader, ...
cacheql
https://github.com/chatterbugapp/cacheql


rest api:  associations with blueprint...


authentication:

time based one time passwords TOTP nach standarad
mit ruby und next.js
https://www.security-insider.de/was-ist-totp-a-875708/

### Associations

The most basic JSON representation would be to show all attributes of a model:

```
{
   "id":163,
   "amount":"12",
   "creditor_id":3,
   "debitor_id":7,
   "paid_at":"2020-05-28"
}
```

This way the client needs another two requests to get information on the debitor and creditor.
We could include this information:

```
{
   "id":163,
   "amount":"12",
   "creditor_id":3,
   "debitor_id":7,
   "paid_at":"2020-05-28"
}
```
