// SPDX-License-Identifier: CC-BY-4.0   
pragma solidity ^0.8.4;

contract MercadoTransferencia {
    
    address private owner;
    
    struct Jogador {
        uint referenciaVenda; // No futuro será gerado uma referencia única pelo próprio contrato no acto de registo do jogador a ser transferido
        string nome;
        uint idade;
        bool isTransferido;
        uint valorDaTransferencia; // Valor da venda em ether
        string nomeActualClube;
        string nomeNovoClube; // Nome do clube de transferência do Jogador
        uint dataDaTransferencia; // Data da realizazao da transferência - block.timestamp
    }
    
    struct TotalTransferencia {
        uint totalJogadorTransferidos;
        uint totalJogadorPorTransferir;
    }
    
    mapping(address => Jogador[]) private transferenciasDeJogadores;
    mapping(address => TotalTransferencia) private informacaoTotalTransferencias;
    Jogador[] private listaDeTransferenciasDeJogadores;
    
    bool public isMercadoTransferenciaAberto;
    uint public dataRealizacaoMercadoDeTransferencia;
    
    constructor() {
        owner = msg.sender; // Atribuir o endereco do dono do contrato no momento da publicao do contrato na Blockchain
        isMercadoTransferenciaAberto = false;
        dataRealizacaoMercadoDeTransferencia = 0;
    }
    
    event TrocoDaCompraJogador(address endereco, uint troco);
    event MercadoDeTransferenciaAberto(address endereco);
    event MercadoDeTransferenciaFechado(address endereco);
    
    modifier donoContratoParticipaMercadoTransf() {
        require(msg.sender != owner, "O dono do contrato nao pode participar no mercado de transferencias.");
        _;
    }
    
     modifier responsavelAberturaDoMercado() {
        require(msg.sender == owner, "Apenas o dono do contrato pode realizar a abertura do mercado de transferencias.");
        _;
    }
    
    modifier mercadoAberto() {
        require(isMercadoTransferenciaAberto, "O mercado de transferencias encontra-se fechado.");
        _;
    }
    
      modifier mercadoFechado() {
        require(!isMercadoTransferenciaAberto, "O mercado de transferencias encontra-se aberto.");
        _;
    }
    
    function registarJogadorASerTransferido(uint _referenciaVenda, string memory _nomeJogador, uint _idade, uint _valorDaTransferencia, string memory _nomeActualClube) 
        public mercadoAberto donoContratoParticipaMercadoTransf {
            Jogador[] storage jogadores =  transferenciasDeJogadores[msg.sender];
            Jogador memory jogador = Jogador(_referenciaVenda, _nomeJogador, _idade, false, _valorDaTransferencia, _nomeActualClube, "", 0);
            jogadores.push(jogador);
            
            TotalTransferencia storage totalTransferencia = informacaoTotalTransferencias[msg.sender];
            totalTransferencia.totalJogadorPorTransferir++;
            
            listaDeTransferenciasDeJogadores.push(jogador);
    }
    
    function getTotalTransferidosPorTransferir(bool _transferidoOuPorTransferir) private view returns(uint) {
        if(_transferidoOuPorTransferir) {
            return informacaoTotalTransferencias[msg.sender].totalJogadorTransferidos;
        }
        return informacaoTotalTransferencias[msg.sender].totalJogadorPorTransferir;
    }
        
    function listaDeJogadores(bool _transferidoOuPorTransferir) private view returns(Jogador[] memory) {
        Jogador[] memory listaJogadores = new Jogador[](getTotalTransferidosPorTransferir(_transferidoOuPorTransferir));
        
        uint index = 0; 
        for(uint i = 0; i < listaDeTransferenciasDeJogadores.length; i++) {
            if(listaDeTransferenciasDeJogadores[i].isTransferido == _transferidoOuPorTransferir){
                listaJogadores[index] = listaDeTransferenciasDeJogadores[i];
                index++;
            }
        }
        
        return listaJogadores;
    }
                    
    function listaJogadoresTransferidos() public view returns(Jogador[] memory) {
        return listaDeJogadores(true);
    }
    
      function listaJogadoresPorTransferir() public view returns(Jogador[] memory) {
          return listaDeJogadores(false);
    }
    
    
    function efectuarTransferenciaJogador(uint referenciaVenda, address payable endereco) public payable mercadoAberto donoContratoParticipaMercadoTransf {
        Jogador[] storage _listaDeTransferenciasDeJogadores = listaDeTransferenciasDeJogadores;
        
        require(_listaDeTransferenciasDeJogadores.length > 0, "Nao existem jogadores no mercado de transferencia.");
        
        for(uint i = 0; i < _listaDeTransferenciasDeJogadores.length; i++) {
            if(_listaDeTransferenciasDeJogadores[i].isTransferido == false && _listaDeTransferenciasDeJogadores[i].referenciaVenda == referenciaVenda) {
                
                _listaDeTransferenciasDeJogadores[i].isTransferido = true;
                _listaDeTransferenciasDeJogadores[i].dataDaTransferencia = block.timestamp;
                
                TotalTransferencia storage totalTransferencia = informacaoTotalTransferencias[endereco];
                totalTransferencia.totalJogadorPorTransferir--;
                totalTransferencia.totalJogadorTransferidos++;
                
                if(msg.value > _listaDeTransferenciasDeJogadores[i].valorDaTransferencia) {
                    uint troco = msg.value - _listaDeTransferenciasDeJogadores[i].valorDaTransferencia;
                    endereco.transfer(troco);
                    emit TrocoDaCompraJogador(endereco, troco); break;
                }
                
                require(msg.value == _listaDeTransferenciasDeJogadores[i].valorDaTransferencia, "O valor transferido nao e suficiente para efectuar a compra do jogador.");
                break;
            }
        }
    }
    
    function abrirMercadoDeTransferencias(uint _dataRealizacaoMercadoDeTransferencia) public mercadoFechado responsavelAberturaDoMercado {
        require(_dataRealizacaoMercadoDeTransferencia > block.timestamp, "Data de realizacao invalida.");
        isMercadoTransferenciaAberto = true;
        dataRealizacaoMercadoDeTransferencia = _dataRealizacaoMercadoDeTransferencia;
        emit MercadoDeTransferenciaAberto(msg.sender);
    }
    
    function encerrarMercadoDeTransferencias() public mercadoAberto responsavelAberturaDoMercado {
        isMercadoTransferenciaAberto = false;
        dataRealizacaoMercadoDeTransferencia = 0;
        emit MercadoDeTransferenciaFechado(msg.sender);
    }
}
