#/usr/bin/env python
from __future__ import division, print_function
from matplotlib import pyplot as plt
import numpy as np
LIGHT_SPEED = 2.998e8  # meters / second
MEGA = (10 ** 6)


def megahertz_to_wavelength(mega_hertz):
    # convert to hertz
    hertz = mega_hertz * MEGA
    # define variables in the frequency, speed, wavelength equation
    # l = wavelength in meters           (usually denoted as lambda)
    # f = frequency  in hz               (usually denoted as nu)
    # c = speed      in meters / second
    c = LIGHT_SPEED
    f = hertz
    w = c / f
    # return computed wavelength
    wavelength = w
    return wavelength


megahertz_list = np.linspace(88.0, 108, 100)
wavelengths_list = map(megahertz_to_wavelength, megahertz_list)

megahertz_list_special = [97.7, 102.7, 106.5]
wavelengths_list_special = map(megahertz_to_wavelength, megahertz_list_special)


plt.plot(megahertz_list, wavelengths_list, 'r-')
plt.plot(megahertz_list_special, wavelengths_list_special, 'ro')
ax = plt.gca()
ax.set_title('radio station wavelengths as a function of frequency')
ax.set_ylabel('wavelength (meters)')
ax.set_xlabel('frequency (megahertz)')
#ax.set_yscale('symlog')
plt.show()
