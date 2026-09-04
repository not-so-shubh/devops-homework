'use strict';

const express = require('express');

const app = express();
const port = Number(process.env.PORT || 3000);

app.disable('x-powered-by');
app.get('/', (_request, response) => {
  response
    .status(200)
    .type('html')
    .send('<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Node.js Hello</title></head><body><main><h1>Hello World from Node.js</h1></main></body></html>');
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Node.js service listening on port ${port}`);
});
