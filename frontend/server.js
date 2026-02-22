const fastify = require('fastify')({ logger: true });
const http = require('http');

const APP_ALB = process.env.APP_ALB_DNS || "missing-alb";
const AZ = process.env.AZ || "missing-AZ";


fastify.get('/', async (request, reply) => {
  return `
    <h1>Frontend (Fastify)</h1>
    <br>
    <h1>Instance is running in:</h1>
    <h2 id="AZ">Loading...</h2>
    <h2 id="backend">Loading...</h2>

    <script>
      fetch('/backend')
        .then(r => r.text())
        .then(t => document.getElementById("backend").innerText = t)
        .catch(() => document.getElementById("backend").innerText = "Error contacting backend");

      fetch('/AZ')
        .then(r => r.text())
        .then(t => document.getElementById("AZ").innerText = t)
        .catch(() => document.getElementById("AZ").innerText = "Error could not get AZ");
    </script>
  `;
});

fastify.get('/backend', async (request, reply) => {
  return new Promise((resolve, reject) => {
    http.get(`http://${APP_ALB}`, res => {
      let data = '';

      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve(data));
    }).on('error', reject);
  });
});

fastify.get('/AZ', async (request, reply) => {
  return AZ;
});

fastify.listen({ port: 3000, host: '0.0.0.0' });
