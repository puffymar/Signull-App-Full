import 'dotenv/config';
import express from 'express';
import aistories from './aistories.js';

const app = express();
app.use(express.json({ limit: '1mb' }));

app.get('/healthz', (_req, res) => res.json({ ok: true }));
app.use('/v1/aistories', aistories);

const port = process.env.PORT || 8787;
app.listen(port, () => console.log(`SIGNULL API listening on :${port}`));
