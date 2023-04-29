ganache-cli \ --fork https://goerli.infura.io/v3/a12b4dfeb504407c9b995c6a773e3800 --unlock 0x7bBfecDCF7d0E7e5aA5fffA4593c26571824CB87

truffle run verify ExerciceSolution@0x5f451D07e14cd9873C95c2299108A92b399FC57a --network goerli

truffle test debug --network goerli_fork test/test.js
