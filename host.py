import qsharp
import qutip
import math
import numpy as np
import matplotlib.pyplot as plt

from TestFPAA import FixedPointAmplify, NewFixedPointAmplify, DumpStatePreparation

def angle_to_probability(theta):
    return abs(math.cos(theta))

def compute_probabilities(nb_data_points):
    
    theta_array = np.linspace(0, math.pi/2, nb_data_points)
    input_p1_array = [angle_to_probability(theta) for theta in theta_array]
    output_p1_array = []
    new_output_p1_array = []

    for theta in theta_array:
        with qsharp.capture_diagnostics(as_qobj=True) as diagnostics:
            FixedPointAmplify.simulate(theta=theta)
            NewFixedPointAmplify.simulate(theta=theta)
        state_vector = diagnostics[0].data.data
        new_state_vector = diagnostics[1].data.data
        p1 = abs(state_vector[1])**2
        new_p1 = abs(new_state_vector[1])**2
        output_p1_array.append(p1)
        new_output_p1_array.append(new_p1)
        
    return input_p1_array, output_p1_array, new_output_p1_array

def plot_FPAA():
    input_p1_array, output_p1_array, new_output_p1_array = compute_probabilities(nb_data_points=1000)
    plt.title(r"Fixed point amplification of $\langle 0 | U | 0 \rangle$ instead of $\langle 1 | U | 0 \rangle$ ?")
    plt.plot(input_p1_array, new_output_p1_array, label='with opposite AboutTarget phases')
    plt.plot(input_p1_array, output_p1_array, label='with current phases')
    plt.xlabel(r"$p_1$ before amplification")
    plt.ylabel(r"$p_1$ after amplification")
    plt.legend()
    plt.savefig("plots/FPAA_diagnostics")
    plt.show()

plot_FPAA()

def test_state_preparation(theta):
    print("theta/pi:", theta/math.pi)
    with qsharp.capture_diagnostics() as diagnostics:
        DumpStatePreparation.simulate(theta=theta)
    magnitude_a1 = diagnostics[0]["amplitudes"]["1"]["Magnitude"]
    print("magnitude_a1:", magnitude_a1)
    p1 = magnitude_a1**2
    print("p1:", p1)

# theta = math.pi/3
# test_state_preparation(theta)



