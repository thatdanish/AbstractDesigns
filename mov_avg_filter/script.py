import numpy as np
import matplotlib.pyplot as plt


taps = 8
COEFF_BITS = 8
DATA_BITS = 16
OUTPUT_BITS = 32

def todecimal(val, bits):
    x = int(val, 2)
    s = 1 << (bits - 1)
    return (x & (s - 1)) - (x & s)

real_coeff = 1/8
real_coeff_bin = np.binary_repr(int(real_coeff*(2**(COEFF_BITS-1))), COEFF_BITS)
# print(real_coeff_bin)
converted_real_coeff = todecimal(real_coeff_bin, COEFF_BITS)/(2**(COEFF_BITS-1))

# Test data generation 
timeaxis = np.linspace(0, 4*np.pi, 1000)
data = np.sin(2*timeaxis) + 0.3*np.random.randn(len(timeaxis))


original_data = []
for val in data:
    val_bin = np.binary_repr(int(val*(2**(COEFF_BITS-1))), DATA_BITS)
    original_data.append(val_bin)

with open("original.data", "w") as file:
    for val in original_data:
        file.write(val+"\n")

# Filtered data retrieval
filtered_data = []
filtered_data_bin = []
with open("filtered.data", "r") as file:
    for line in file:
        filtered_data_bin.append(line.rstrip("\n"))

for val in filtered_data_bin[1:]:
    val_dec = todecimal(val, OUTPUT_BITS)/(2**((2*COEFF_BITS-1)))
    filtered_data.append(val_dec)

plt.plot(data, color='blue', label="Original data")
plt.plot(filtered_data, color='red', label="Filtered data")
plt.legend()
plt.savefig("image.png", dpi=600)
plt.show()