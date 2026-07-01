const http = require('http');

const data = JSON.stringify({
  name: "Test User",
  email: "randomuser5@example.com",
  password: "password123"
});

const req = http.request({
  hostname: 'localhost',
  port: 8000,
  path: '/api/auth/signup',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': data.length
  }
}, res => {
  let body = '';
  res.on('data', d => body += d);
  res.on('end', () => console.log('Response:', body));
});

req.write(data);
req.end();
