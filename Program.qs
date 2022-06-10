namespace TestFPAA {

    open Microsoft.Quantum.Intrinsic;     
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.AmplitudeAmplification;
    open Microsoft.Quantum.Oracles;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Arrays;

    operation FixedPointAmplify(theta : Double) : Unit {

        let epsilon = 0.1;
        let successMin = 1. - epsilon;
        let nQueries = 9; 
        let phases = FixedPointReflectionPhases(nQueries, successMin);

        let startStateReflection = ReflectionStart();
        let myStateOracle = StateOracle (StatePreparationWithFlagIndex(theta,_,_));
        let flagIndex = 0;

        let MyAmplifiedOperation = AmplitudeAmplificationFromStatePreparation(
            phases, myStateOracle, flagIndex
        );
        
        use singleQubitRegister = Qubit[1];
        MyAmplifiedOperation (singleQubitRegister);
        DumpMachine();
        ResetAll(singleQubitRegister);

    }

    operation NewFixedPointAmplify(theta : Double) : Unit {

        let epsilon = 0.1;
        let successMin = 1. - epsilon;
        let nQueries = 9; 
        let phases = FixedPointReflectionPhases(nQueries, successMin);
        // Message($"target phases : {phases::AboutTarget}");
        let newAboutTargetPhases = Mapped(opposite, phases::AboutTarget);
        // Message($"new target phases : {newAboutTargetPhases}");
        let newPhases = ReflectionPhases(phases::AboutStart, newAboutTargetPhases);

        let startStateReflection = ReflectionStart();
        let myStateOracle = StateOracle (StatePreparationWithFlagIndex(theta,_,_));
        let flagIndex = 0;

        let MyAmplifiedOperation = AmplitudeAmplificationFromStatePreparation(
            newPhases, myStateOracle, flagIndex
        );
        
        use singleQubitRegister = Qubit[1];
        MyAmplifiedOperation (singleQubitRegister);
        DumpMachine();
        ResetAll(singleQubitRegister);

    }

    operation StatePreparationWithFlagIndex(theta : Double, flagIndex : Int, register : Qubit[]) : Unit is Adj + Ctl {
        StatePreparation (theta, register);
    }

    operation StatePreparation(theta : Double, singleQubitRegister : Qubit[]) : Unit is Ctl + Adj {
        let qubit = singleQubitRegister[0];
        Ry(PI() - 2.*theta, qubit); // Ry(pi - 2*theta) has amplitude cos(theta) in <1|.|0>.
    }

    function opposite (x : Double) : Double {
        return -x;
    }

    operation DumpStatePreparation (theta : Double) : Unit {
        use qubit = Qubit();
        StatePreparation(theta, [qubit]);
        DumpMachine();
        Reset(qubit);
    }
}