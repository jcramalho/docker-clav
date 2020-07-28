var permissions = require("./CLAV-auth/config/permissions.js")
var fs = require("fs")
var acesso = []

function getIndex(permission){
    return acesso.findIndex(e => permission == e.nivel);
}

function buildNivel(nivel, desc){
    return {
        nivel: nivel,
        desc: desc,
        ops: []
    }
}

function buildRota(verbo, rota, desc){
    return {
        verbo: verbo,
        path: rota.replace(/\/\{api_version\}/g, ""),
        desc: desc
    }
}

function getRotaDesc(verbo, rota){
    var desc = ""

    let r = rota.replace(/:/g, "~")
    r = r.replace(/\/\{api_version\}/g, "")

    try{
        let dados = fs.readFileSync("./CLAV2018/swagger/paths" + r + "/" + verbo.toLowerCase() + ".yaml", {encoding: "utf-8"})
        desc = dados.match(/summary:[^\n]*/)[0]
        desc = desc.split("summary: ")[1]
    }catch{
        if(verbo == "GET"){
            switch(rota){
                case "/{api_version}/docs":
                    desc = "Documentação da API de dados"
                    break
                case "/(.*)":
                    desc = "Ficheiros públicos da API de dados"
                    break
                default:
                    desc = ""
                    break
            }
        }else{
            desc = ""
        }
    }

    return desc
}

acesso.push(buildNivel(-1, "Qualquer pessoa"))
acesso.push(buildNivel(0, "Chaves API"))
acesso.push(buildNivel(1, "Representante Entidade"))
acesso.push(buildNivel(2, "Utilizador Simples"))
acesso.push(buildNivel(3, "Utilizador Avançado"))
acesso.push(buildNivel(3.5, "Utilizador Validador (AD)"))
acesso.push(buildNivel(4, "Utilizador Validador"))
acesso.push(buildNivel(5, "Utilizador Decisor"))
acesso.push(buildNivel(6, "Administrador de Perfil Funcional"))
acesso.push(buildNivel(7, "Administrador de Perfil Tecnológico"))

for(let verbo in permissions){
    for(let rota in permissions[verbo]){
        let rotaDesc = getRotaDesc(verbo, rota)

        if(permissions[verbo][rota] instanceof Array){
            for(let perm of permissions[verbo][rota]){
                acesso[getIndex(perm)].ops.push(buildRota(verbo, rota, rotaDesc))
            }
        }else if(permissions[verbo][rota] == -1){
            let index = getIndex(permissions[verbo][rota])
            acesso[index].ops.push(buildRota(verbo, rota, rotaDesc))
        }else{
            let index = getIndex(permissions[verbo][rota])
            for(var i = index; i < acesso.length; i++){
                acesso[i].ops.push(buildRota(verbo, rota, rotaDesc))
            }
        }
    }
}

console.log(JSON.stringify(acesso, null, 4))
