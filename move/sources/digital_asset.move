module my_addrx::artemis_one {
    use aptos_framework::event;
    use aptos_framework::object;
    use aptos_framework::object::ExtendRef;
    use aptos_token_objects::collection;
    use aptos_token_objects::token;
    use std::error;
    use std::option;
    use std::signer::address_of;
    use std::string::{Self, String};
    #[test_only]
    use aptos_std::debug::print;

    const ENOT_AVAILABLE: u64 = 1;
    const ENAME_LIMIT: u64 = 2;
    const ENOT_CREATOR: u64 = 3;

    const NAME_UPPER_BOUND: u64 = 64;
    const APP_OBJECT_NAME: vector<u8> = b"ARTEMIS COLLECTIVE ONE";
    const ARTEMIS_COLLECTION_NAME: vector<u8> = b"Artemis One";
    const ARTEMIS_COLLECTION_DESCRIPTION: vector<u8> = b"Tokenized artworks curated by Arteesan";
    const ARTEMIS_COLLECTION_URI: vector<u8> = b"https://arteesan.io/images/logo-h.svg";

    struct Asset has key {
        name: String,
        artist: String,
        arteesan_url: String,
        mutator_ref: token::MutatorRef,
        burn_ref: token::BurnRef
    }

    #[event]
    struct MintAssetEvent has drop, store {
        asset_name: String,
    }

    struct ObjectController has key {
        app_extend_ref: ExtendRef,
    }

    fun init_module(account: &signer) {
        let constructor_ref = object::create_named_object(
            account,
            APP_OBJECT_NAME,
        );
        let extend_ref = object::generate_extend_ref(&constructor_ref);
        let app_signer = &object::generate_signer(&constructor_ref);

        move_to(app_signer, ObjectController {
            app_extend_ref: extend_ref,
        });

        create_artemis_collection(app_signer);
    }

    fun get_app_signer_addr(): address {
        object::create_object_address(&@my_addrx, APP_OBJECT_NAME)
    }

    fun get_app_signer(): signer acquires ObjectController {
        object::generate_signer_for_extending(&borrow_global<ObjectController>(get_app_signer_addr()).app_extend_ref)
    }

    // Create the collection that will hold all the asset
    fun create_artemis_collection(creator: &signer) {
        let description = string::utf8(ARTEMIS_COLLECTION_DESCRIPTION);
        let name = string::utf8(ARTEMIS_COLLECTION_NAME);
        let uri = string::utf8(ARTEMIS_COLLECTION_URI);

        collection::create_unlimited_collection(
            creator,
            description,
            name,
            option::none(),
            uri,
        );
    }

    // fun create_fa() acquires ObjectController {
    //
    // }

    // Create a tokenized asset object
    public entry fun create_asset(
        user: &signer,
        name: String,
        artist: String,
        arteesan_url: String,
    ) acquires ObjectController {
        assert!(address_of(user) == address_of(&get_app_signer()), error::invalid_argument(ENOT_CREATOR));
        assert!(string::length(&name) <= NAME_UPPER_BOUND, error::invalid_argument(ENAME_LIMIT));

        let uri = string::utf8(ARTEMIS_COLLECTION_URI);
        let description = string::utf8(ARTEMIS_COLLECTION_DESCRIPTION);

        let constructor_ref = token::create_named_token(
            &get_app_signer(),
            string::utf8(ARTEMIS_COLLECTION_NAME),
            description,
            name,
            option::none(),
            uri,
        );

        let token_signer = object::generate_signer(&constructor_ref);
        let mutator_ref = token::generate_mutator_ref(&constructor_ref);
        let burn_ref = token::generate_burn_ref(&constructor_ref);
        let transfer_ref = object::generate_transfer_ref(&constructor_ref);

        // initialize/set default Aptogotchi struct values
        let asset = Asset {
            name,
            artist,
            arteesan_url,
            mutator_ref,
            burn_ref,
        };

        move_to(&token_signer, asset);

        // Emit event for minting Aptogotchi token
        event::emit<MintAssetEvent>(
            MintAssetEvent {
                asset_name: name
            },
        );

        object::transfer_with_ref(object::generate_linear_transfer_ref(&transfer_ref), address_of(user));
    }
}
