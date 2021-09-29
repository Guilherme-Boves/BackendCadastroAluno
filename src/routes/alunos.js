// API REST de Alunos
import express from 'express'
import sql from 'mssql'
import { sqlConfig } from '../sql/config.js'
const router = express.Router()

/******************************************
 * GET /alunos
 * Retornar a lista de todos os alunos
 *****************************************/
router.get("/", (req, res) => {
    try{
        sql.connect(sqlConfig).then(pool => {
            return pool.request()
            .execute('SP_S_ALU_ALUNO')
        }).then(dados => {
            res.status(200).json(dados.recordset)
        }).catch(err => {
            res.status(400).json(err) //400 - bad request
        })
    } catch (err){
        console.log(err)
    }
})

/******************************************
 * GET /alunos/:matricula
 * Retornar um aluno através da matricula
 ******************************************/
 router.get("/:matricula", (req, res) => {
     const matricula = req.params.matricula
    try{
        sql.connect(sqlConfig).then(pool => {
            return pool.request()
            .input('matricula', sql.Int, matricula)
            .execute('SP_S_ALU_ALUNO_MATRICULA')
        }).then(dados => {
            res.status(200).json(dados.recordset)
        }).catch(err => {
            res.status(400).json(err) //400 - bad request
        })
    } catch (err){
        console.log(err)
    }
})

/******************************************
 * POST /alunos/
 * Insere um novo aluno
 ******************************************/
router.post("/", (req, res) => {
    sql.connect(sqlConfig).then(pool => {
        const {matricula, nome, curso, genero, nascimento, rg, email, celular} = req.body
        return pool.request()
        .input('matricula', sql.Int, matricula)
        .input('nome', sql.VarChar(50), nome)
        .input('curso', sql.VarChar(50), curso)
        .input('genero', sql.VarChar(25), genero)
        .input('nascimento', sql.Date, nascimento)
        .input('rg', sql.Char(12), rg)
        .input('email', sql.VarChar(50), email)
        .input('celular', sql.VarChar(15), celular)        
        .output('codigogerado', sql.Int)
        .execute('SP_I_ALU_ALUNO')
    }).then(dados => {
        res.status(200).json(dados.output)
    }).catch(err => {
        res.status(400).json(err.message) // Bad request
    })
})

/******************************************
 * PUT /alunos
 * Altera os dados de um aluno
 ******************************************/
 router.put("/", (req, res) => {
    sql.connect(sqlConfig).then(pool => {
        const {matricula, nome, curso, genero, nascimento, rg, email, celular} = req.body
        return pool.request()
        .input('matricula', sql.Int, matricula)
        .input('nome', sql.VarChar(50), nome)
        .input('curso', sql.VarChar(50), curso)
        .input('genero', sql.VarChar(25), genero)
        .input('nascimento', sql.Date, nascimento)
        .input('rg', sql.Char(12), rg)
        .input('email', sql.VarChar(50), email)
        .input('celular', sql.VarChar(15), celular)
        .execute('SP_U_ALU_ALUNO')
    }).then(dados => {
        res.status(200).json('Cadastro do aluno alterado com sucesso!')
    }).catch(err => {
        res.status(400).json(err.message) // Bad request
    })
})

/******************************************
 * DELETE /alunos/:matricula
 * Apaga um aluno pela matricula
 ******************************************/
router.delete('/:matricula', (req, res) => {
    sql.connect(sqlConfig).then(pool => {
        const matricula = req.params.matricula
        return pool.request()
        .input('matricula', sql.Int, matricula)
        .execute('SP_D_ALU_ALUNO')
    }).then(dados => {
        res.status(200).json('Cadastro do aluno excluido com sucesso!')
    }).catch(err => {
        res.status(400).json(err.message)
    })
})


export default router