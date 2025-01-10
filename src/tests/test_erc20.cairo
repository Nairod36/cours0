#[cfg(test)]
mod test_erc20 {
    use starknet::test_utils::{
        start_rollup, build_block_context, deploy_contract
    };
    use starknet::ContractAddress;
    use crate::core::SimpleERC20::SimpleERC20Impl; // On importe l’impl
    use crate::core::SimpleERC20::Storage;
    use crate::core::SimpleERC20::ContractState;

    #[test]
    fn test_initial_supply() {
        // On lance l’environnent de test
        start_rollup();
        let bc = build_block_context();

        // Deploy du contrat (avec des arguments fictifs)
        let (contract_addr, mut contract_state) = deploy_contract::<ContractState>(
            // Path vers le fichier compiled
            "target/dev/my_erc20_project.sierra.json",
            // Inputs du constructor, par ex.: name_, symbol_, initial_supply (low, high), owner
            &[
                "MYTOKEN",        // name_ (felt)
                "MTK",            // symbol_ (felt)
                "1000", "0",      // initial_supply => 1000 en u256 (low=1000, high=0)
                "0x123"           // owner
            ],
            bc.clone()
        );

        // On check le totalSupply
        let total_supply = SimpleERC20Impl::totalSupply(@contract_state);
        assert_eq!(total_supply, (1000, 0)); // (low=1000, high=0)

        // Optionnel : On check la balance du owner
        let owner_balance = SimpleERC20Impl::balanceOf(@contract_state, ContractAddress::from_hex("0x123"));
        assert_eq!(owner_balance, (1000, 0));
    }
}