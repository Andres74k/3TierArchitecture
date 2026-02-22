const fastify = require('fastify')({ logger: true });
const http = require('http');

const APP_ALB = process.env.APP_ALB_DNS || "missing-alb";
const AZ = process.env.AZ || "missing-AZ";


fastify.get('/', async (request, reply) => {
  reply.type('text/html');
  return `
  <html>
  <head>
    <title>Frontend</title>
    <style>
      body {
        margin: 0;
        padding: 40px;
        font-family: Arial, sans-serif;
        background: linear-gradient(135deg, #0f172a, #020617);
        color: #e5e7eb;
      }

      h1 {
        margin: 0;
        margin-bottom: 10px;
      }

      h2 {
        margin: 5px 0;
        font-weight: normal;
      }

      .container {
        max-width: 900px;
        margin: auto;
      }

      .card {
        background: #1e293b;
        border-radius: 14px;
        padding: 20px;
        margin-top: 20px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.35);
      }

      .label {
        font-size: 13px;
        color: #94a3b8;
        margin-bottom: 8px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
      }

      .value {
        font-size: 20px;
        font-weight: bold;
      }

      table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 10px;
        background: #0f172a;
        border-radius: 8px;
        overflow: hidden;
      }

      th {
        background: #334155;
        text-align: left;
        padding: 12px;
        font-size: 14px;
      }

      td {
        padding: 12px;
        border-bottom: 1px solid #1e293b;
      }

      tr:hover {
        background: #1e293b;
      }

      .error {
        color: #f87171;
        font-weight: bold;
      }

      .loading {
        color: #94a3b8;
      }
    </style>
  </head>

  <body>
    <div class="container">
      <h1>Frontend (Fastify)</h1>

      <div class="card">
        <div class="label">Availability Zone</div>
        <div class="value" id="AZ">Loading...</div>
      </div>

      <div class="card">
        <div class="label">Backend Response</div>
        <div class="value" id="backend">Loading...</div>
      </div>

      <div class="card">
        <div class="label">Users from Database</div>
        <div id="users" class="loading">Loading...</div>
      </div>
    </div>

    <script>
      fetch('/backend')
        .then(r => r.text())
        .then(t => document.getElementById("backend").innerText = t)
        .catch(() =>
          document.getElementById("backend").innerHTML =
            "<span class='error'>Error contacting backend</span>"
        );

      fetch('/AZ')
        .then(r => r.text())
        .then(t => document.getElementById("AZ").innerText = t)
        .catch(() =>
          document.getElementById("AZ").innerHTML =
            "<span class='error'>Error retrieving AZ</span>"
        );

      fetch('/users')
        .then(r => r.json())
        .then(users => {
          if (users.error) {
            document.getElementById("users").innerHTML =
              "<span class='error'>" + users.error + "</span>";
            return;
          }

          let html = "<table>";
          html += "<tr><th>ID</th><th>Name</th></tr>";

          users.forEach(u => {
            html += "<tr><td>" + u.id + "</td><td>" + u.name + "</td></tr>";
          });

          html += "</table>";

          document.getElementById("users").innerHTML = html;
        })
        .catch(() =>
          document.getElementById("users").innerHTML =
            "<span class='error'>Error contacting backend</span>"
        );
    </script>
  </body>
  </html>
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

      res.on('end', () => {
        if (res.statusCode !== 200) {
          return reject(new Error(`Backend returned ${res.statusCode}`));
        }

        resolve(data);
      });
    }).on('error', reject);
  });
}

fastify.listen({ port: 3000, host: '0.0.0.0' });
