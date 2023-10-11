type modular_congruences_system = (int * int) list

let remainders_smaller system =
  let rec aux = function
    | (modulus, remainder) :: t -> remainder < modulus && aux t
    | [] -> true
  in
  aux system

let rec negatives = function
  | (modulus, remainder) :: t -> (modulus < 0 || remainder < 0) || negatives t
  | [] -> false

let rec remainders_zeros = function
  | (_, 0) :: t -> remainders_zeros t
  | [] -> true
  | _ -> false

let rec gcd x y = if y = 0 then x else gcd y (x mod y)

let moduli_pairwise_coprimes system =
  let rec aux i i' n = function
    | (modulus, _) :: t -> (i' = i || gcd n modulus = 1) && aux i (i' + 1) n t
    | [] -> true
  in
  let rec aux' i = function
    | (modulus, _) :: t -> aux i 0 modulus system && aux' (i + 1) t
    | [] -> true
  in
  aux' 0 system

let solvable system =
  if negatives system then failwith "Remainders and moduli must be non negatives."
  else if not (remainders_smaller system) then failwith "Remainders must be smaller than moduli."
  else if not (moduli_pairwise_coprimes system) then failwith "Moduli must be pairwise coprimes."
  else true

(** [prod(n1, n2, ..., nk)] *)
let rec product_of_moduli = function
  | (modulus, _) :: t -> modulus * product_of_moduli t
  | [] -> 1

(** [x in nx == 1 (mod m)] using the Extended Euclidean Algorithm. *)
let mod_inv n m =
  let rec aux a b t t' s s' =
    if a mod b = 0 then if t' < 0 then t' + m else t' else
    let q = a / b in
    let t'', s'' = t - (t' * q) , s - (s' * q) in aux b (a mod b) t' t'' s' s''
  in aux n m 1 0 0 1

(** [lcm(n1, n2, ..., nk)] *)
let lcm_of_system system =
  let lcm x y = x * (y / gcd x y) in
  let rec aux result = function
    | (modulus, _) :: t -> aux (lcm result modulus) t
    | [] -> result
  in
  match system with
  | (a, _) :: (b, _) :: t -> aux (lcm a b) t
  | _ -> failwith ""

(** Returns [(Sol, Sol (mod N))]. *)
let solve_system (system : modular_congruences_system) =
  let rec aux product result = function
    | (modulus, remainder) :: t ->
        let product' = product / modulus in
        let inverse = mod_inv product' modulus in
        let result = result + (remainder * product' * inverse) in
        aux product result t
    | [] -> (result, result mod product)
  in
  let prod = product_of_moduli system in
  if List.length system = 0 then failwith "Empty system."
  else if remainders_zeros system then let s = lcm_of_system system in s, s mod prod
  else let _ = solvable system in aux prod 0 system

open Printf

let print_solutions = function g, s -> printf "S: %d | S (mod N): %d.\n" g s

let main () =
  print_solutions (solve_system [ (2, 0); (3, 1); (5, 4); (7, 0); (13, 9) ]);
  print_solutions (solve_system [ (12, 1); (17, 16); (29, 9) ]);
  print_solutions (solve_system [ (4, 0); (6, 0) ])
let () = main ()