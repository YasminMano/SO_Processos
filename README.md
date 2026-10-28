# Exercício 1 — Criando Órfãos e Zumbis

Atividade da disciplina de **Sistemas Operacionais**, desenvolvida em **Zig 0.16.0** e executada em uma máquina virtual **Alpine Linux**.

## Enunciado / proposta da atividade

**Referência:** slide **“Exercício 1: Criando Órfãos e Zumbis”**, página 5 do material `processos-3.pdf` (*Dominando Processos no Linux com Zig*).

O slide apresenta:

- Um exemplo de `fork()` em que o **processo pai encerra cedo**, enquanto o **processo filho permanece executando por 5 segundos**, demonstrando a situação de **processo órfão** e sua adoção por outro processo (`init` no diagrama).
- Um diagrama de **processo zumbi**, no qual o **filho terminou**, mas o **pai ainda está vivo e não recolheu o status** de saída.

> **Nota:** a descrição acima resume a proposta visual do slide; ela **não é uma transcrição de requisitos de entrega**. O slide não determina, por exemplo, nomes de arquivos, formato de relatório ou uso de argumentos de linha de comando. A implementação abaixo reúne as duas demonstrações em um arquivo, conforme a organização escolhida para a atividade.

## Objetivo

Entender o ciclo de vida de processos no Linux, mostrando na prática as diferenças entre:

| Situação | O que acontece? |
| --- | --- |
| **Órfão** | O pai termina antes do filho; o filho continua executando e é adotado por outro processo. |
| **Zumbi** | O filho termina antes do pai; enquanto seu status não é recolhido, um registro permanece na tabela de processos com estado `Z`. |

## Implementação

O código-fonte da atividade está em **[`exercicio1.zig`](./exercicio1.zig)**. O programa aceita um argumento para executar um dos casos:

- `orfao`: usa `std.os.linux.fork()` para criar o filho. O pai encerra imediatamente; o filho aguarda 5 segundos e consulta `getppid()` para observar seu processo pai atual.
- `zumbi`: cria o filho, que encerra imediatamente. O pai permanece vivo por 15 segundos **sem chamar `waitpid()`**, permitindo observar o filho com estado `Z` durante esse intervalo.

Foi utilizada a API de baixo nível `std.os.linux`, compatível com o ambiente Linux adotado. A leitura de argumentos é feita em `main(init: std.process.Init)`, conforme a versão 0.16.0 do Zig. O arquivo `mise.toml` fixa a versão da ferramenta para reproduzir o ambiente.

## Ambiente utilizado

- **Sistema operacional:** Alpine Linux (máquina virtual)
- **Compilador:** Zig `0.16.0`
- **Gerenciador de versões:** `mise`
- **Terminal:** shell do Alpine, acessado por SSH a partir do PowerShell

## Como compilar e executar

Abra o terminal dentro da pasta do repositório.

**1. Conferir a versão do Zig:**

```sh
mise exec -- zig version
```

Resultado esperado: `0.16.0`.

**2. Compilar:**

```sh
mise exec -- zig build-exe exercicio1.zig
```

**3. Demonstrar processo órfão:**

```sh
./exercicio1 orfao
```

O pai pode encerrar antes de o filho imprimir todas as mensagens. Aguarde cerca de cinco segundos para observar o PPID final do filho.

**4. Demonstrar processo zumbi:**

```sh
./exercicio1 zumbi & sleep 2; ps -o pid,ppid,stat,comm | grep exercicio1
```

O `&` coloca o programa em segundo plano; `sleep 2` dá tempo para o filho encerrar; e `ps` consulta os estados enquanto o pai ainda está aguardando. Esse comando foi testado com o `ps` do **BusyBox** no Alpine Linux.

## Evidências da execução

### Processo órfão

Saída observada em teste:

```text
PAI: Meu PID e 2458
FILHO: Meu PID e 2459
PAI: Criei o filho 2459 e vou terminar.
FILHO: Meu PPID atual e 2458
FILHO: Depois de 5 segundos, meu PPID e 1
```

O filho iniciou com PPID `2458`, correspondente ao pai original, e depois passou a ter PPID `1` (`init`), demonstrando sua adoção após o encerramento do pai.

### Processo zumbi

Saída observada em teste:

```text
FILHO: Meu PID e 2480
PAI: Meu PID e 2478
PAI: Filho criado com PID 2480
PAI: Esperando 15 segundos sem waitpid().
FILHO: Encerrando agora.
 2478  2281 S    exercicio1
 2480  2478 Z    exercicio1
```

Na saída de `ps`:

- **PID 2478 — `S`:** o pai está vivo, dormindo durante a espera.
- **PID 2480 — `Z`:** o filho já encerrou, mas seu status ainda não foi recolhido.

> Os PIDs e a ordem das mensagens variam entre execuções, pois o escalonador do Linux determina quando cada processo executa.

## Conceitos importantes

- **`fork()`**: cria um processo filho. No filho, o retorno é `0`; no pai, é o PID do filho.
- **`getpid()`**: retorna o PID do processo atual.
- **`getppid()`**: retorna o PID do processo pai atual.
- **`exit(0)`**: encerra o processo com código de saída `0`.
- **`waitpid()`**: permite ao pai aguardar/coletar o status de saída do filho. A ausência dessa coleta, enquanto o pai vive, possibilita a observação de um zumbi.
- **`STAT=Z`**: indica processo zumbi na saída de `ps`.

## Conclusão

O exercício demonstrou duas situações diferentes do ciclo de vida de processos no Linux. No primeiro caso, o filho permaneceu executando após o encerramento do pai e foi adotado pelo processo de PID 1. No segundo, o filho encerrou antes do pai e permaneceu temporariamente registrado como zumbi (`Z`). Os dois comportamentos foram implementados e testados usando **um único arquivo-fonte, `exercicio1.zig`**.

## Referência

Material de aula: **`processos-3.pdf`**, página 5 — *Exercício 1: Criando Órfãos e Zumbis*.
