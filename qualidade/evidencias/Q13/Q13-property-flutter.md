# Q13 — Evidência de Property-Based Testing: Flutter

**Data:** 02/10/2026  
**Arquivo de Teste:** `test/features/qualidade/q13_fuzz_property_test.dart`  
**Seed Canônica Global:** `130013`  

---

## 1. Visão Geral e Princípios Metodológicos

Os testes baseados em propriedades da fase Q13 foram desenvolvidos de forma puramente determinística utilizando geradores com seed fixa (`kFixedSeed = 130013`), dispensando bibliotecas externas complexas para garantir total portabilidade, estabilidade e capacidade de reprodução exata.

Cada propriedade testa um contrato lógico invariante do domínio contra centenas de combinações geradas dinamicamente.

---

## 2. Resumo de Execução das Propriedades (Flutter)

| Property | Alvo | Seed | Iterações | Invariante Testada | Resultado |
|---|---|---:|---:|---|---|
| **P01** | `UsuarioCarteira` e `PerfilUsuario` | `130013` | 100 | Roundtrip `jsonEncode(dto.toJson())` seguido de `fromJson()` restaura propriedades essenciais | **100% PASSOU** (0 discrepâncias) |
| **P02** | Validadores e Formatters | `130014` | 200 | Entradas nulas, vazias, espaços, acentos, unicode e símbolos não causam exceção não tratada | **100% PASSOU** (0 exceções) |
| **P03** | `OuvidoriaProvider._isValidCPF` | `130015` | 500 | 500 CPFs matematicamente válidos são aceitos; a alteração do dígito verificador resulta em rejeição imediata | **100% PASSOU** (500/500 aceitos, 500/500 rejeitados) |
| **P04** | `TelefoneInputFormatter` | `130016` | 500 | Entradas de 10 dígitos geram máscara `(XX) XXXX-XXXX`; 11 dígitos geram `(XX) XXXXX-XXXX`; dígitos originais são preservados | **100% PASSOU** (500/500 conformes) |
| **P05** | `ServicoLinksExternos.uriEmail` | `130017` | 200 | URIs geradas possuem scheme `mailto` e path correspondente ao e-mail informado | **100% PASSOU** (200/200 conformes) |
| **P06** | `NoticiaState` e Providers | N/A (Estado) | Determinístico | Estados finais de sucesso ou falha sempre garantem `isLoading == false` e sanitização de `errorMessage` | **100% PASSOU** (Invariante confirmada) |
| **P07** | `sessionResetProvider` | N/A (Sessão) | Determinístico | Transição de sessão ativa para logout invalida atômica e integralmente o estado de providers privados | **100% PASSOU** (Invariante confirmada) |

---

## 3. Detalhamento das Invariantes de Domínio

### P01: Roundtrip de Serialização/Desserialização
- **Modelos Auditados:** `UsuarioCarteira` e `PerfilUsuario`.
- **Invariante:** Para todo objeto com dados válidos, `fromJson(toJson(obj))` preserva:
  - Campos textuais (`nome`, `cargo`, `matricula`, `email`, `orgaoNome`);
  - Tratamento de nulos sem corrupção;
  - Resiliência na conversão de identificadores numéricos e strings.

### P03: Validador de Algoritmo de CPF
- **Gerador:** Algoritmo determinístico de módulo 11 gerando os 9 dígitos aleatórios e calculando os dígitos verificadores $D_1$ e $D_2$.
- **Adulteração:** O último dígito foi propositalmente deslocado $((D_2 + 1 + r) \pmod{10})$.
- **Invariante:**
  - $CPFs_{validos} \implies \text{nextStep}() == \text{null}$ (avanço de etapa permitido);
  - $CPFs_{corrompidos} \implies \text{nextStep}() \neq \text{null}$ (erro `CPF inválido` retornado).
- **Resultado:** 500 aceitações e 500 rejeições exatas registradas.

### P04: Formatação de Telefones Fixos e Móveis
- **Regra:**
  - Comprimento 10 $\implies$ formato `(XX) XXXX-XXXX`;
  - Comprimento 11 $\implies$ formato `(XX) XXXXX-XXXX`;
  - Caracteres numéricos extraídos são estritamente idênticos aos dígitos originais fornecidos.
