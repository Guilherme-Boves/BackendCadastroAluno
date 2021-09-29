import express from "express";

const app = express()
const port = 4000

app.use(express.urlencoded({extended: true})) //converterá caracteres especiais em html entity
app.use(express.json()) //fará o parse no conteúdo json
app.disable('x-powered-by') //Removendo por questões de segurança

import rotasAlunos from './routes/alunos.js'

//Rotas Restfull do nosso app
app.use('/api/alunos', rotasAlunos)

//definimos a nossa rota default
app.get('/api', (req, res) => {
    res.status(200).json({
        mensagem: 'API do Cadastro Aluno 100% funcional!',
        versao: '1.0.0'
    })
})

//Rota de conteúdo público
app.use('/', express.static('public'))

//Rota para tratar erros 404
app.use(function(req, res){
    res.status(404).json({
        mensagem: `A rota ${req.originalUrl} não existe!`
    })
}) 

app.listen(port, function(){
    console.log(`Servidor web rodando na porta ${port}`)
})
