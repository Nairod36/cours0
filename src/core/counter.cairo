#[starknet::contract]
mod Counter {
    use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePathEntry};

    #[storage]
    struct Storage {
        value: u256,
        map:Map::<ContractAddress,u256>,
        allowed:Map::<ContractAddress,bool>
    }
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Update: Update,
    }

    #[derive(Drop, starknet::Event)]
    struct Update {
        #[key]
        value: u256,
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_value: u256) {
        self.value.write(initial_value);
        self.allowed.entry(get_caller_address()).write(true)
    }

    #[abi(embed_v0)]
    impl CounterImpl of counter::interfaces::Counter::ICounter<ContractState> {
        fn change_value(ref self: ContractState, value: u256) {
            assert(self.allowed.entry(get_caller_address()).read() == false, 'nan');
                self.value.write(self.value.read() + value);
                self.map.entry(get_caller_address()).write(self.value.read() + value);
                self.emit(Update { value: value });
            
            
        }

        fn get_value(self: @ContractState, address: ContractAddress) -> u256 {
            self.map.entry(address).read()
        }
    }
}
