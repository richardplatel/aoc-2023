#!/usr/bin/env python3
# -*- coding:utf-8 -*-


# from sympy import solve
# from sympy.abc import x, y, z
# solve([x + y - 2*z, y + 4*z], [x, y], dict=True)
# [{x: 6*z, y: -4*z}]

import sympy
from sympy import solve
from sympy.abc import a, b, c, t, u, v, x, y, z

unknowns = [a, b, c, t, u, v, x, y, z]
equations = [
sympy.Eq(x + a * t, 171178400007298 + 190 * t),
sympy.Eq(y + b * t, 165283791547432 + 186 * t),
sympy.Eq(z + c * t, 246565404194007 + 60 * t),

sympy.Eq(x + a * u, 250314870325177 + 45 * u),
sympy.Eq(y + b * u, 283762496814661 + 15 * u),
sympy.Eq(z + c * u, 272019235409859 + 8 * u),

sympy.Eq(x + a * v, 192727134181171 + 22 * v),
sympy.Eq(y + b * v, 456146317292988 - 541 * v),
sympy.Eq(z + c * v, 246796112051543 - 70 * v)
]

s = sympy.solve(equations, unknowns, dict=True)
print(s)
print(s[0][x] + s[0][y] + s[0][z])
