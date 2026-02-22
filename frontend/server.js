const fastify = require('fastify')({ logger: true });
const http = require('http');

const APP_ALB = process.env.APP_ALB_DNS || "missing-alb";


fastify.get('/', async (request, reply) => {
  return `
    <h1>Frontend (Fastify)</h1>
    <br>
    <h1>Instance is running in:</h1>
    <h2>$AZ</h2>
    <h2 id="backend">Loading...</h2>

    <script>
      fetch('/backend')
        .then(r => r.text())
        .then(t => document.getElementById("backend").innerText = t)
        .catch(() => document.getElementById("backend").innerText = "Error contacting backend");
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

fastify.listen({ port: 3000, host: '0.0.0.0' });
