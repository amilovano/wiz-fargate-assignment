const express = require("express");
const { MongoClient } = require("mongodb");

const app = express();

const mongoUri =
  process.env.MONGO_URI ||
  "mongodb://localhost:27017";

let db = null;

MongoClient.connect(mongoUri)
  .then(client => {
    db = client.db("wizdb");
    console.log("Connected to MongoDB");
  })
  .catch(err => {
    console.log("Mongo unavailable, continuing startup");
    console.log(err.message);
  });

app.get("/", async (req, res) => {
  try {
    if (db) {
      await db.collection("visits").insertOne({
        timestamp: new Date()
      });
    }

    res.send("Wiz demo app");
  } catch (err) {
    res.status(500).send(err.message);
  }
});

app.get("/health", (req, res) => {
  res.json({
    status: "healthy",
    database: db ? "connected" : "not connected"
  });
});

app.listen(3000, () => {
  console.log("App running on port 3000");
});