const express = require("express");
const { Pool } = require("pg");

const app = express();

const pool = new Pool({
    host: process.env.DB_HOST || "localhost",
    user: process.env.DB_USER || "postgres",
    password: process.env.DB_PASSWORD || "postgres",
    database: process.env.DB_NAME || "appdb",
    port: 5432
});

app.get("/", async(req,res)=>{

    try {

        const result = await pool.query(
            "SELECT NOW()"
        );

        res.json({
            status:"healthy",
            dbTime: result.rows[0]
        });

    } catch(err){

        res.status(500).json({
            error: err.message
        });

    }

});

app.listen(3000,()=>{

console.log("App running on port 3000")

});