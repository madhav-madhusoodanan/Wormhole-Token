pragma circom 2.1.5;

include "./circomlib/circuits/poseidon.circom";
include "./circomlib/circuits/bitify.circom";

template IndicesGenerator() {
    signal input in;
    signal output out[160];

    // Need to check if input is less than 2 ** 161
    component aliasCheck = AliasCheck();
    component n2b = Num2Bits(254);
    in ==> n2b.in;

    for (var i=0; i<254; i++) {
        n2b.out[i] ==> aliasCheck.in[i];
    }

    for (var i=0; i<160; i++) {
        n2b.out[i] ==> out[i];
    }
}

template AddressGenerator() {
    signal input in[160];
    signal output out;
    
    signal modifiedInput[254];
    
    for(var i=0; i<160; i++){
    	modifiedInput[i] <== in[i];
    }
    
    for(var i=160; i<254; i++){
    	modifiedInput[i] <== 0;
    }

    component aliasCheck = AliasCheck();
    component b2n = Bits2Num(254);

    for (var i=0; i<254; i++) {
        modifiedInput[i] ==> b2n.in[i];
        modifiedInput[i] ==> aliasCheck.in[i];
    }

    b2n.out ==> out;
}


// Computes Poseidon([left, right])
template HashLeftRight() {
    signal input left;
    signal input right;
    signal output hash;

    component hasher = Poseidon(2);
    hasher.inputs[0] <== left;
    hasher.inputs[1] <== right;
    hash <== hasher.out;
}

// s indicates whether input will be switched or not
// if s == 0 DualMux returns [in[0], in[1]]
// if s == 1 DualMux returns [in[1], in[0]]
template DualMux() {
    signal input in[2];
    signal input s;
    signal output out[2];

    s * (1 - s) === 0;
    out[0] <== (in[1] - in[0])*s + in[0];
    out[1] <== (in[0] - in[1])*s + in[1];
}


// Generates the root without sharing information about the Merkle tree path needed to generate it.
template MerkleTree(levels) {
    // compact this email bytes
    signal input balance;
    signal input nullifier;
    signal input obfuscator;
    signal input pathElements[160];
    
    // this root must strictly be an existing root
    signal output root;

    component selectors[levels];
    component hashers[levels];
    
    signal tempAddress <== Poseidon(2)([nullifier, obfuscator]);
    
    signal pathIndices[160] <== IndicesGenerator()(tempAddress);
    // signal address <== AddressGenerator()(pathIndices);
    // log(address);
    signal leaf <== Poseidon(2)([balance, balance]);
    
    for (var i = 0; i < levels; i++) {
        selectors[i] = DualMux();
        selectors[i].in[0] <== i == 0 ? leaf : hashers[i - 1].hash;
        selectors[i].in[1] <== pathElements[i];
        selectors[i].s <== pathIndices[i];
        
        // log(selectors[i].in[0]);

        hashers[i] = HashLeftRight();
        hashers[i].left <== selectors[i].out[0];
        hashers[i].right <== selectors[i].out[1];
    }

    root <== hashers[levels - 1].hash;

}


component main{ public[balance, nullifier] } = MerkleTree(160);
