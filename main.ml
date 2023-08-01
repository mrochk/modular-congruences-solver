type modular_congruences_system = (int * int) list

let remainders_smaller system =
  let rec aux = function
    | [] -> true
    | (modulus, remainder) :: t -> remainder < modulus && aux t
  in
  aux system

let rec negatives = function
  | [] -> false
  | (modulus, remainder) :: t -> 
    (modulus < 0 || remainder < 0) || negatives t

let rec remainders_zeros = function
  | [] -> true
  | (_, 0) :: t -> remainders_zeros t
  | _ -> false

let rec gcd x y = if y = 0 then x else gcd y (x mod y)

let moduli_pairwise_coprimes system =
  let rec aux i i' n = function
    | [] -> true
    | (modulus, _) :: t ->
        (i' = i || gcd n modulus = 1) && aux i (i' + 1) n t
  in
  let rec aux' i = function
    | [] -> true
    | (modulus, _) :: t -> aux i 0 modulus system && aux' (i + 1) t
  in
  aux' 0 system

let solvable system =
  if negatives system then
    failwith "Remainders and moduli must be non negatives."
  else if not (remainders_smaller system) then
    failwith "Remainders must be smaller than moduli."
  else if not (moduli_pairwise_coprimes system) then
    failwith "Moduli must be pairwise coprimes."
  else true

(** Returns n1*n2*...*nk. *)
let rec product_of_moduli = function
  | [] -> 1
  | (modulus, _) :: t -> modulus * product_of_moduli t

(** Returns the Bezout's coefficients k and l such that gcd(x, y) = xk + yl. *)
let rec bezout's_coefficients a b =
  let rec aux x y =
    if x = 0 then (0, 1)
    else
      let k, l = aux (y mod x) x in
      (l - (y / x * k), k)
  in
  aux a b

(** Returns the modular inverse of n with respect to modulus m. *)
let modular_inverse n m =
  let k = fst (bezout's_coefficients n m) in
  if k < 0 then k + m else k

(** Returns lcm(n1, n2, ..., nk). *)
let lcm_of_system system =
  let lcm x y = x * (y / gcd x y) in
  let rec aux result = function
    | [] -> result
    | (modulus, _) :: t -> aux (lcm result modulus) t
  in
  match system with
  | (a, _) :: (b, _) :: t -> aux (lcm a b) t
  | _ -> failwith ""

(** Returns a pair of integers: (general solution, smallest solution). *)
let solve_system (system : modular_congruences_system) =
  let rec aux product result = function
    | [] -> (result, result mod product)
    | (modulus, remainder) :: t ->
        let product' = product / modulus in
        let inverse = modular_inverse product' modulus in
        let result = result + (remainder * product' * inverse) in
        aux product result t
  in
  if List.length system = 0 then failwith "Empty system."
  else if remainders_zeros system then (lcm_of_system system, 0)
  else let _ = solvable system in aux (product_of_moduli system) 0 system

open Printf

let print_solutions = function
  | g, s -> printf "General solution: %d | Smallest solution: %d.\n" g s

let () =
  print_solutions (solve_system [ (3, 1); (5, 2); (7, 6) ]);
  print_solutions (solve_system [ (2, 0); (3, 1); (5, 4); (7, 0); (13, 9) ]);
  print_solutions (solve_system [ (12, 1); (17, 16); (29, 9) ]);
  print_solutions (solve_system [ (20, 0); (19, 0); (18, 0); (17, 0); (16, 0); 
                                  (15, 0); (14, 0); (13, 0); (12, 0); (11, 0); ]);
  ()
