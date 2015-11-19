module.exports = [
  {path: /\/api\/auth.*/, scope: 'user', strategies: ['anyone']}
  {path: /\/api.*/, scope: 'user'}
]