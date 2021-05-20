// SPDX-License-Identifier: CC-BY-4.0   
pragma solidity ^0.8.4;

contract Calculadora {
    
    enum Operacao {
        SOMA,
        SUBTRACAO,
        MULTIPLICACAO,
        DIVISAO
    }
    
    int private resultadoOperacao;
    
    function soma(int num1, int num2) public {
        calcular(Operacao.SOMA, num1, num2);
    }
    
    function subtracao(int num1, int num2) public  {
       calcular(Operacao.SUBTRACAO, num1, num2);
    }
    
    function multiplicacao(int num1, int num2) public {
        calcular(Operacao.MULTIPLICACAO, num1, num2);
    }
    function divisao(int num1, int num2) public {
        calcular(Operacao.DIVISAO, num1, num2);
    }
    
    function calcular(Operacao _operacao, int num1, int num2) private {
        if(_operacao == Operacao.SOMA) {
            resultadoOperacao = num1 + num2;
        } else if(_operacao == Operacao.SUBTRACAO) {
            resultadoOperacao = num1 - num2;
        } else if(_operacao == Operacao.MULTIPLICACAO) {
            resultadoOperacao = num1 * num2;
        } else {
            num1 / num2;
        }
    }
    
    function obterResultaOperacao() public view returns(int) {
        return resultadoOperacao;
    }
    
}
