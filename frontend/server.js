const fastify = require('fastify')({ logger: true });
const http = require('http');

const APP_ALB = process.env.APP_ALB_DNS || "missing-alb";
const AZ = process.env.AZ || "missing-AZ";


fastify.get('/', async (request, reply) => {
  reply.type('text/html');
  return `
    <h1>Frontend (Fastify)</h1>
    <br>
    <h1>Instance is running in:</h1>
    <h2 id="AZ">Loading...</h2>
    <h2 id="backend">Loading...</h2>
    <h2>Users from Database:</h2>
    <div id="users">Loading...</div>

    <script>
      fetch('/backend')
        .then(r => r.text())
        .then(t => document.getElementById("backend").innerText = t)
        .catch(() => document.getElementById("backend").innerText = "Error contacting backend");

      fetch('/AZ')
        .then(r => r.text())
        .then(t => document.getElementById("AZ").innerText = t)
        .catch(() => document.getElementById("AZ").innerText = "Error could not get AZ");

      fetch('/users')
        .then(r => r.json())
        .then(users => {
          if (users.error) {
            document.getElementById("users").innerText = users.error;
            return;
          }

          let html = "<table border='1'><tr><th>ID</th><th>Name</th></tr>";

          users.forEach(u => {
            html += "<tr><td>" + u.id + "</td><td>" + u.name + "</td></tr>";
          });

          html += "</table>";

          document.getElementById("users").innerHTML = html;
        })
        .catch(() => {
          document.getElementById("users").innerText = "Error contacting backend";
        });
    </script>
  `;
});

fastify.get('/backend', async (request, reply) => {
  try {
    const data = await callBackend('');
    return data;
  } catch (err) {
    reply.code(500);
    return { error: 'Backend / Backend unreachable' };
  }
});

fastify.get('/users', async (request, reply) => {
  try {
    const data = await callBackend('users');
    return JSON.parse(data);
  } catch (err) {
    reply.code(500);
    return { error: 'Backend / DB unreachable' };
  }
});

fastify.get('/AZ', async (request, reply) => {
  return AZ;
});

function callBackend(path) {
  return new Promise((resolve, reject) => {
    http.get(`http://${APP_ALB}/${path}`, res => {
      let data = '';

      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve(data));
    }).on('error', reject);
  });
}

fastify.listen({ port: 3000, host: '0.0.0.0' });
