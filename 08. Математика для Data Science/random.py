# -*- coding: utf-8 -*-
"""
Created on Sat Nov  2 11:46:29 2024

@author: shran
"""

import random as rd
import numpy as np

str_= '0123456789Roma@#'
password = ''
for i in range(1, len(str_)+1):
    pas_ = rd.choice(str_)
    password += pas_
print(password)
print(len(password))


wer = np.linspace(2, 10, 20)
qw = np.random.choice(wer, size=5)
print(type(qw))


mat = np.rando

