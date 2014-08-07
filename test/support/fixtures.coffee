

module.exports = 
  clientId:  '01234567890123456789000a'
  accountId: '01234567890123456789000b'

  invalidOauthAppId:'0123456789012345678900aa'

  invalidOauthApp:
    description: "This is a dummy"
    isInternal: false

  oauthApp1:
    name: "app1"
    description: "This is a app 1"
    isInternal: false

  oauthApp2:
    name: "app2"
    description: "This is a app 2"
    isInternal: false

  oauthAppInternal1:
    name: "app3"
    description: "This is a app 3"
    isInternal: true


  invalidOauthScopeId:'0123456789012345678900ba'

  invalidOauthScope:
    description: "This is a dummy"
    isInternal: false

  oauthScope1:
    name: "scope1"
    description: "This is scope 1"
    isInternal: false

  oauthScope2:
    name: "scope2"
    description: "This is scope 2"
    isInternal: false

  oauthScopeInternal1:
    name: "scope3"
    description: "This is scope 3"
    isInternal: true




  credentialsUser:
    id: "13a88c31413019245de27da7"
    username: 'Martin Wawrusch'
    accountId: '13a88c31413019245de27da0'
    roles: []

  credentialsServerAdmin:
    id: "13a88c31413019245de27da0"
    username: 'John Smith'
    accountId: '13a88c31413019245de27da0'
    roles: []
    scopes: ['server-admin']
