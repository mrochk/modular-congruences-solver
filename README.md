# Modular Congruences Solver
Little program to solve a system of modular congruences.

Assume the following linear system,
$$x \equiv a_1 \pmod{n_1}$$
$$x \equiv a_2 \pmod{n_2}$$
$$\vdots$$
$$x \equiv a_k \pmod{n_k}$$
and $n_1, n_2, \dots, n_k \in \mathbb{N_0}$ are either pairwise coprimes or all equal to $0$.

In this program, a system of congruences is represented as an OCaml list of `(modulus, remainder)` pairs of integers.

If $\forall n \in \lbrace  n_1, n_2, \dots, n_k \rbrace $, $n = 0$, we return $lcm ( n_1,n_2,\dots, n_{k-1}, n_k )$ as the general solution, and $0$ as the smallest.

Else, the [Chinese Remainder Theorem](https://brilliant.org/wiki/chinese-remainder-theorem/) states that this system has a solution $S$, and ($S$ modulo $N = n_1 n_2 \dots n_k$) is the unique solution $\in$ $[0, N-1]$.

***How do I compute the modular inverse ?***

Observe that the function `modular_inverse n m` returns the first Bezout's coefficient $k$ (from `bezout's_coefficients`, that uses the [Extended Euclidean Algorithm](https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm)) such that $nk + ml = \gcd(n, m)$.

Since $\gcd(\frac{N}{n_i}, n_i) = 1$ (since we require pairwise coprimes moduli),
$$\frac{N}{n_i}k + n_{i}l \equiv 1 \pmod{n_i}$$
$$\frac{N}{n_i}k \equiv 1 \pmod{n_i}$$

$\implies$ $k$ is the modular multiplicative inverse of $\frac{N}{n_i}$ with respect to the modulus $n_i$.
