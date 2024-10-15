module my_addrx::artemis_one {
    use aptos_framework::event;
    use aptos_framework::object::{Self, ExtendRef, Object};
    use aptos_framework::fungible_asset::{Self, Metadata, MintRef, TransferRef, BurnRef, FungibleAsset};
    use aptos_framework::primary_fungible_store;
    use aptos_token_objects::collection;
    use aptos_token_objects::token;
    use std::error;
    use std::option;
    use std::option::Option;
    use std::signer;
    use std::signer::address_of;
    use std::string::{Self, String};
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::coin;


    const ENOT_AVAILABLE: u64 = 1;
    const ENAME_LIMIT: u64 = 2;
    const ENOT_CREATOR: u64 = 3;
    const ENOT_OWNER: u64 = 4;
    const EPAUSED: u64 = 5;
    const EINVALID_PRICE: u64 = 6;
    const EINSUFFICIENT_BALANCE: u64 = 7;
    const EASSET_NOT_FOUND: u64 = 8;
    const EINVALID_AMOUNT: u64 = 9;
    const EINSUFFICIENT_TOKENS: u64 = 10;
    const EASSET_NOT_REDEEMABLE: u64 = 11;

    const NAME_UPPER_BOUND: u64 = 64;
    const APP_OBJECT_NAME: vector<u8> = b"ARTEMIS COLLECTIVE ONE";
    const ARTEMIS_COLLECTION_NAME: vector<u8> = b"Artemis One";
    const ARTEMIS_COLLECTION_DESCRIPTION: vector<u8> = b"Tokenized artworks curated by Arteesan";
    const ARTEMIS_COLLECTION_URI: vector<u8> = b"https://arteesan.io/images/logo-h.svg";
    const ASSET_SYMBOL: vector<u8> = b"ART01";

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct ManagedFungibleAsset has key {
        mint_ref: MintRef,
        transfer_ref: TransferRef,
        burn_ref: BurnRef,
    }

    struct Asset has key {
        name: String,
        artist: String,
        arteesan_url: String,
        token_symbol: String,
        price_per_token: u64,
        mutator_ref: token::MutatorRef,
        burn_ref: token::BurnRef
    }

    #[event]
    struct MintAssetEvent has drop, store {
        asset_name: String,
    }

    #[event]
    struct CreateTokenEvent has drop, store {
        token_name: String,
        token_symbol: String,
        total_supply: u128,
    }

    #[event]
    struct MintFungibleTokenEvent has drop, store {
        amount: u64,
        recipient: address,
    }

    #[event]
    struct PurchaseTokenEvent has drop, store {
        buyer_address: address,
        asset_name: String,
        amount: u64,
        total_price: u128
    }

    #[event]
    struct AssetClaimEvent has drop, store {
        claimer: address,
        asset_name: String,
        burned_tokens: u64,
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

    // Create a tokenized asset object
    public entry fun create_asset(
        creator: &signer,
        name: String,
        artist: String,
        arteesan_url: String,
        token_name: String,
        token_symbol: String,
        token_supply: u128,
        price_per_token: u64
    ) acquires ObjectController {
        assert!(address_of(creator) == @my_addrx, error::invalid_argument(ENOT_CREATOR));
        assert!(string::length(&name) <= NAME_UPPER_BOUND, error::invalid_argument(ENAME_LIMIT));
        assert!(price_per_token > 0, error::invalid_argument(EINVALID_PRICE));

        let description = string::utf8(ARTEMIS_COLLECTION_DESCRIPTION);
        let constructor_ref = token::create_named_token(
            &get_app_signer(),
            string::utf8(ARTEMIS_COLLECTION_NAME),
            description,
            name,
            option::none(),
            arteesan_url,
        );

        let token_signer = object::generate_signer(&constructor_ref);
        let mutator_ref = token::generate_mutator_ref(&constructor_ref);
        let burn_ref = token::generate_burn_ref(&constructor_ref);
        let transfer_ref = object::generate_transfer_ref(&constructor_ref);
        let asset = Asset {
            name,
            artist,
            arteesan_url,
            token_symbol,
            price_per_token,
            mutator_ref,
            burn_ref,
        };

        move_to(&token_signer, asset);
        event::emit<MintAssetEvent>(
            MintAssetEvent {
                asset_name: name
            },
        );

        object::transfer_with_ref(object::generate_linear_transfer_ref(&transfer_ref), address_of(creator));
        create_token(creator, token_name, token_symbol, token_supply);
    }

    fun create_token(
        creator: &signer,
        name: String,
        symbol: String,
        total_supply: u128,
    ) acquires ObjectController {
        let constructor_ref = &object::create_named_object(
            &get_app_signer(),
            *string::bytes(&symbol)
        );

        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            constructor_ref,
            option::some(total_supply),
            name,
            symbol,
            0,
            string::utf8(b"https://artemiscolletive.xyz/favicon.ico"), /* icon */
            string::utf8(b"https://artemiscolletive.xyz"), /* project */
        );

        let mint_ref = fungible_asset::generate_mint_ref(constructor_ref);
        let burn_ref = fungible_asset::generate_burn_ref(constructor_ref);
        let transfer_ref = fungible_asset::generate_transfer_ref(constructor_ref);
        let metadata_object_signer = object::generate_signer(constructor_ref);

        event::emit(CreateTokenEvent {
            token_name: name,
            token_symbol: symbol,
            total_supply,
        });

        let fa = fungible_asset::mint(&mint_ref, (total_supply as u64));
        let creator_address = signer::address_of(creator);
        let creator_store = primary_fungible_store::ensure_primary_store_exists(
            creator_address,
            object::object_from_constructor_ref<Metadata>(constructor_ref));

        fungible_asset::deposit_with_ref(&transfer_ref, creator_store, fa);

        event::emit(MintFungibleTokenEvent {
            amount: (total_supply as u64),
            recipient: creator_address,
        });

        move_to(
            &metadata_object_signer,
            ManagedFungibleAsset { mint_ref, transfer_ref, burn_ref }
        );
    }

    #[view]
    /// Return the address of the managed fungible asset that's created when this module is deployed.
    public fun get_metadata(token_symbol: vector<u8>): Object<Metadata> acquires ObjectController {
        // let asset_address = object::create_object_address(&@my_addrx, token_symbol);
        // object::address_to_object<Metadata>(asset_address)

        let app_signer = get_app_signer();
        let app_signer_addr = signer::address_of(&app_signer);
        let asset_address = object::create_object_address(&app_signer_addr, token_symbol);
        object::address_to_object<Metadata>(asset_address)
    }

    public entry fun mint(
        admin: &signer,
        to: address,
        amount: u64,
        symbol: vector<u8>
    ) acquires ManagedFungibleAsset, ObjectController {
        let asset = get_metadata(symbol);
        let managed_fungible_asset = authorized_borrow_refs(admin, asset);
        let to_wallet = primary_fungible_store::ensure_primary_store_exists(to, asset);
        let fa = fungible_asset::mint(&managed_fungible_asset.mint_ref, amount);
        fungible_asset::deposit_with_ref(&managed_fungible_asset.transfer_ref, to_wallet, fa);
    }// <:!:mint

    public entry fun transfer(
        admin: &signer,
        from: address,
        to: address,
        amount: u64,
        symbol: vector<u8>
    ) acquires ManagedFungibleAsset, ObjectController {
        let asset = get_metadata(symbol);
        let transfer_ref = &authorized_borrow_refs(admin, asset).transfer_ref;
        let from_wallet = primary_fungible_store::primary_store(from, asset);
        let to_wallet = primary_fungible_store::ensure_primary_store_exists(to, asset);
        let fa = withdraw(from_wallet, amount, transfer_ref);
        deposit(to_wallet, fa, transfer_ref);
    }

    public entry fun burn(
        admin: &signer,
        from: address,
        amount: u64,
        symbol: vector<u8>
    ) acquires ManagedFungibleAsset, ObjectController {
        let asset = get_metadata(symbol);
        let burn_ref = &authorized_borrow_refs(admin, asset).burn_ref;
        let from_wallet = primary_fungible_store::primary_store(from, asset);
        fungible_asset::burn_from(burn_ref, from_wallet, amount);
    }

    public entry fun freeze_account(
        admin: &signer,
        account: address,
        symbol: vector<u8>
    ) acquires ManagedFungibleAsset, ObjectController {
        let asset = get_metadata(symbol);
        let transfer_ref = &authorized_borrow_refs(admin, asset).transfer_ref;
        let wallet = primary_fungible_store::ensure_primary_store_exists(account, asset);
        fungible_asset::set_frozen_flag(transfer_ref, wallet, true);
    }

    public entry fun unfreeze_account(
        admin: &signer,
        account: address,
        symbol: vector<u8>
    ) acquires ManagedFungibleAsset, ObjectController {
        let asset = get_metadata(symbol);
        let transfer_ref = &authorized_borrow_refs(admin, asset).transfer_ref;
        let wallet = primary_fungible_store::ensure_primary_store_exists(account, asset);
        fungible_asset::set_frozen_flag(transfer_ref, wallet, false);
    }

    public entry fun purchase_fractional_ownership(
        buyer: &signer,
        amount: u64,
        asset_name: String
    ) acquires ObjectController, Asset, ManagedFungibleAsset {
        let buyer_addr = signer::address_of(buyer);
        let app_signer = get_app_signer();
        let app_signer_addr = signer::address_of(&app_signer);
        let asset_address = token::create_token_address(
            &app_signer_addr,
            &string::utf8(ARTEMIS_COLLECTION_NAME),
            &asset_name
        );
        let asset = borrow_global<Asset>(asset_address);
        let total_price = (amount as u128) * (asset.price_per_token as u128);
        let token_metadata = get_metadata(*string::bytes(&asset.token_symbol));
        assert!(total_price > 0 && total_price <= 18446744073709551615, error::invalid_argument(EINVALID_PRICE));
        assert!(
            coin::balance<AptosCoin>(buyer_addr) >= (total_price as u64),
            error::invalid_argument(EINSUFFICIENT_BALANCE)
        );

        let creator_addr = @my_addrx;
        coin::transfer<AptosCoin>(buyer, creator_addr, (total_price as u64));

        let transfer_ref = &borrow_global<ManagedFungibleAsset>(object::object_address(&token_metadata)).transfer_ref;
        let creator_store = primary_fungible_store::primary_store(creator_addr, token_metadata);
        let buyer_store = primary_fungible_store::ensure_primary_store_exists(buyer_addr, token_metadata);
        let fa = withdraw(creator_store, amount, transfer_ref);
        deposit(buyer_store, fa, transfer_ref);

        event::emit(PurchaseTokenEvent {
            buyer_address: buyer_addr,
            asset_name: asset_name,
            amount,
            total_price
        });
    }

    public entry fun claim_asset(
        claimer: &signer,
        asset_name: String
    ) acquires ObjectController, Asset, ManagedFungibleAsset {
        let claimer_addr = signer::address_of(claimer);
        let app_signer = get_app_signer();
        let app_signer_addr = signer::address_of(&app_signer);
        let asset_address = token::create_token_address(
            &app_signer_addr,
            &string::utf8(ARTEMIS_COLLECTION_NAME),
            &asset_name
        );

        let asset = borrow_global<Asset>(asset_address);
        let token_metadata = get_metadata(*string::bytes(&asset.token_symbol));
        let token_supply = fungible_asset::supply(token_metadata);
        assert!(option::is_some(&token_supply), error::invalid_state(EASSET_NOT_REDEEMABLE));

        let redeemer_store = primary_fungible_store::ensure_primary_store_exists(claimer_addr, token_metadata);
        let redeemer_balance = fungible_asset::balance(redeemer_store);
        assert!(check_total_supply(redeemer_balance, token_supply), error::invalid_argument(EINSUFFICIENT_TOKENS));

        let burn_ref = &borrow_global<ManagedFungibleAsset>(object::object_address(&token_metadata)).burn_ref;
        fungible_asset::burn_from(burn_ref, redeemer_store, redeemer_balance);

        let asset_object = object::address_to_object<Asset>(asset_address);
        object::transfer(&app_signer, asset_object, claimer_addr);
        event::emit(AssetClaimEvent {
            claimer: claimer_addr,
            asset_name: asset_name,
            burned_tokens: redeemer_balance,
        });
    }

    fun check_total_supply(balance: u64, supply: Option<u128>): bool {
        if (option::is_none(&supply)) {
            return false
        };
        let total_supply = option::extract(&mut supply);
        (balance as u128) == total_supply
    }

    public fun withdraw<T: key>(
        store: Object<T>,
        amount: u64,
        transfer_ref: &TransferRef,
    ): FungibleAsset {
        fungible_asset::withdraw_with_ref(transfer_ref, store, amount)
    }

    public fun deposit<T: key>(
        store: Object<T>,
        fa: FungibleAsset,
        transfer_ref: &TransferRef,
    ) {
        fungible_asset::deposit_with_ref(transfer_ref, store, fa);
    }

    inline fun authorized_borrow_refs(
        owner: &signer,
        asset: Object<Metadata>,
    ): &ManagedFungibleAsset acquires ManagedFungibleAsset {
        assert!(object::is_owner(asset, signer::address_of(owner)), error::permission_denied(ENOT_OWNER));
        borrow_global<ManagedFungibleAsset>(object::object_address(&asset))
    }
}
