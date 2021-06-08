// SPDX-License-Identifier: CC-BY-4.0   
pragma solidity ^0.8.4;

contract EleicoesEmAngola {
    
    address private owner;
    
    struct AnoEleitoralPeriodoRealizacao {
        uint ano;
        uint dataInicio;
        uint dataFim;
        string partidoVencedor;
    }
    
    struct Votante {
        string nome;
        address endereco;
    }
    
    mapping(uint => mapping(address => bool)) private votos; // informacao dos votantes por ano Eleitral - Value Mapping
    mapping(uint => Votante[]) private votantes; // informacao dos votantes por ano Eleitral - Value Array
    mapping(uint => string[]) private partidosPoliticos; // Partidos politicos organizados por ano Eleitral
    mapping(uint => mapping(string => uint)) private votosPorPartidoEAnosEleitorais;
    
    uint public anoEleitoralActivo;
    
    mapping(uint => AnoEleitoralPeriodoRealizacao) private anosEleitorais;
    
    
    modifier SemAnoEleitoralAberto() {
        require(anoEleitoralActivo == 0, "Existe um processo eleitoral em curso.");
        _;
    }
    
    modifier DonoDoContrato() {
        require(owner == msg.sender, "Apenas o dono do contrato pode realizar esta operacao.");
        _;
    }
    
    modifier AnoEleitoralActivo() {
        require(anoEleitoralActivo > 0, "Nao existe nenhum ano eleitoral activo.");
        _;
    }
    
    event anoEleitoralEncerrado(uint anoEleitoral);
    
    constructor() {
        owner = msg.sender; // Participante reponsavel por definir os anos eleitorais e partidos politicos concorrentes
    }
    
    event NovoAnoEleitoralDefinido(uint anoDeEleicoes, uint DataRealizacao, uint dataEnceramento);
    
    function adicionarAnoEleitoralPeriodoRealizacao(uint _anoEleitoral, uint _dataRealizacao, uint _dataEncerramento) private {
        anoEleitoralActivo = _anoEleitoral;
        anosEleitorais[_anoEleitoral] = AnoEleitoralPeriodoRealizacao(_anoEleitoral, _dataRealizacao, _dataEncerramento, "");   
    }
    
    function definirAnoRealizacaoDasEleicoes(uint _anoEleitoral, uint _dataRealizacao, uint _dataEncerramento) public DonoDoContrato SemAnoEleitoralAberto {
        adicionarAnoEleitoralPeriodoRealizacao(_anoEleitoral, _dataRealizacao, _dataEncerramento);
        emit NovoAnoEleitoralDefinido(_anoEleitoral, _dataRealizacao, _dataEncerramento);
    }
    
    function adicionarPartidosPoliticos(string[] memory _partidosPoliticos) public DonoDoContrato {
        require(anoEleitoralActivo > 0, "Nao existe ano eleitoral activo.");
        partidosPoliticos[anoEleitoralActivo] = _partidosPoliticos;
    }
    
    function obterInformacaoDoAnoEleitoral(uint _anoEleitoral) public view returns(AnoEleitoralPeriodoRealizacao memory) {
        return anosEleitorais[_anoEleitoral];
    }
    
      function obterPartidosPoliticosDoAnoEleitoral(uint _anoEleitoral) public view returns(string[] memory) {
        return partidosPoliticos[_anoEleitoral];
    }
    
    function obterVotos(uint _anoEleitoral) public view returns(Votante[] memory) {
        return votantes[_anoEleitoral];
    }
    
    function votar(string memory _partidoPolitico, string memory _nome) public {
        require(anoEleitoralActivo > 0, "Nao existe ano eleitoral activo.");
        require(!votos[anoEleitoralActivo][msg.sender], "Ja efectuou o seu voto");
        
        mapping(string => uint) storage votosPorPartidos = votosPorPartidoEAnosEleitorais[anoEleitoralActivo];
        votosPorPartidos[_partidoPolitico] = votosPorPartidos[_partidoPolitico] + 1;
        votos[anoEleitoralActivo][msg.sender] = true;
        votantes[anoEleitoralActivo].push(Votante(_nome, msg.sender));
    }
    
    function obterResultadosDeVotacao(uint _anoEleitoral) public view returns(uint[] memory _resultados, string[] memory _partidos) {
       _resultados = new uint[](partidosPoliticos[_anoEleitoral].length);
        
        for(uint i = 0 ; i< partidosPoliticos[_anoEleitoral].length; i++) {
            string memory partido = partidosPoliticos[_anoEleitoral][i];
            _resultados[i] = votosPorPartidoEAnosEleitorais[_anoEleitoral][partido];
        }
        
        return(_resultados, partidosPoliticos[_anoEleitoral]);
    }
    
    function encerrarAnoEleitoral() public DonoDoContrato AnoEleitoralActivo {
        require(anosEleitorais[anoEleitoralActivo].dataFim <= block.timestamp, "Ano eleitoral nao chegou ao periodo de encerramento.");
        uint ano = anoEleitoralActivo;
        registarPartidoVencedor();
        anoEleitoralActivo = 0;
        emit anoEleitoralEncerrado(ano);
    }
    
    function registarPartidoVencedor() private {
        uint maior = 0;
        string memory partidoVencedor = "";
        
        for(uint i = 0; i< partidosPoliticos[anoEleitoralActivo].length; i++) {
            string memory partido = partidosPoliticos[anoEleitoralActivo][i];
            uint voto = votosPorPartidoEAnosEleitorais[anoEleitoralActivo][partido];
            if(voto > maior) {
                maior = voto;
                partidoVencedor = partido;
            }
        }
        anosEleitorais[anoEleitoralActivo].partidoVencedor = partidoVencedor;
    }
}
