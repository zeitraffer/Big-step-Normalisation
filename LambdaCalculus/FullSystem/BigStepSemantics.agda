module FullSystem.BigStepSemantics where
open import FullSystem.Syntax
open import FullSystem.OPE

mutual
  data eval_&_⇓_ : forall {Γ Δ σ} -> Tm Δ σ -> Env Γ Δ -> Val Γ σ -> Set where
    rvar  : forall {Γ Δ σ}{vs : Env Γ Δ}{v : Val Γ σ} -> 
            eval top & (vs << v) ⇓ v
    rsubs : forall {B Γ Δ σ}{t : Tm Δ σ}{ts : Sub Γ Δ}{vs : Env B Γ}{ws v} ->
            evalˢ ts & vs ⇓ ws -> eval t & ws ⇓ v -> eval t [ ts ] & vs ⇓ v
    rlam  : forall {Γ Δ σ τ}{t : Tm (Δ < σ) τ}{vs : Env Γ Δ} ->
            eval λt t & vs ⇓ λv t vs
    rapp  : forall {Γ Δ σ τ}{t : Tm Δ (σ ⇒ τ)}{u : Tm Δ σ}{vs : Env Γ Δ}
            {f : Val Γ (σ ⇒ τ)}{a : Val Γ σ}{v : Val Γ τ} ->
            eval t & vs ⇓ f -> eval u & vs ⇓ a -> f $$ a ⇓ v ->
            eval t $ u & vs ⇓ v
    rzero : forall {Γ Δ}{vs : Env Γ Δ} -> eval zero & vs ⇓ zerov
    rsuc  : forall {Γ Δ}{t : Tm Δ N}{vs : Env Γ Δ}{v : Val Γ N} ->
            eval t & vs ⇓ v -> eval suc t & vs ⇓ sucv v
    rprim : forall {Γ Δ σ}{z : Tm Δ σ}{s t}{vs : Env Γ Δ}{z' s' v} ->
            eval z & vs ⇓ z' -> eval s & vs ⇓ s' -> eval t & vs ⇓ v ->
            {w : Val Γ σ} -> prim z' & s' & v ⇓ w -> eval prim z s t & vs ⇓ w
    rvoid : forall {Γ Δ}{vs : Env Γ Δ} -> eval void & vs ⇓ voidv
    r<,>  : forall {Γ Δ σ τ}{t : Tm Δ σ}{u : Tm Δ τ}{vs : Env Γ Δ}
            {v : Val Γ σ}{w : Val Γ τ} -> eval t & vs ⇓ v -> eval u & vs ⇓ w ->
            eval < t , u > & vs ⇓ < v , w >v
    rfst  : forall {Γ Δ σ τ}{t : Tm Δ (σ × τ)}{vs : Env Γ Δ}
            {v : Val Γ (σ × τ)} -> eval t & vs ⇓ v ->
            {w : Val Γ σ} -> vfst v ⇓ w -> eval fst t & vs ⇓ w 
    rsnd  : forall {Γ Δ σ τ}{t : Tm Δ (σ × τ)}{vs : Env Γ Δ}
            {v : Val Γ (σ × τ)} -> eval t & vs ⇓ v -> 
            {w : Val Γ τ} -> vsnd v ⇓ w -> eval snd t & vs ⇓ w

  data prim_&_&_⇓_ : forall {Γ σ} -> Val Γ σ -> Val Γ (N ⇒ σ ⇒ σ) -> Val Γ N ->
                     Val Γ σ -> Set where
    rprn : forall {Γ σ}{z : Val Γ σ}{s : Val Γ (N ⇒ σ ⇒ σ)}{n : NeV Γ N} ->
           prim z & s & nev n ⇓ nev (primV z s n)
    rprz : forall {Γ σ}{z : Val Γ σ}{s : Val Γ (N ⇒ σ ⇒ σ)} ->
           prim z & s & zerov ⇓ z
    rprs : forall {Γ σ}{z : Val Γ σ}{s : Val Γ (N ⇒ σ ⇒ σ)}{v : Val Γ N} ->
           {f : Val Γ (σ ⇒ σ)} -> s $$ v ⇓ f -> 
           {w : Val Γ σ} -> prim z & s & v ⇓ w -> 
           {w' : Val Γ σ} -> f $$ w ⇓ w' ->
           prim z & s & sucv v ⇓ w'

  data vfst_⇓_ : forall {Γ σ τ} -> Val Γ (σ × τ) -> Val Γ σ -> Set where
    rfst<,> : forall {Γ σ τ}{v : Val Γ σ}{w : Val Γ τ} -> vfst < v , w >v ⇓ v
    rfstnev : forall {Γ σ τ}{n : NeV Γ (σ × τ)} -> vfst nev n ⇓ nev (fstV n) 

  data vsnd_⇓_ : forall {Γ σ τ} -> Val Γ (σ × τ) -> Val Γ τ -> Set where
    rsnd<,> : forall {Γ σ τ}{v : Val Γ σ}{w : Val Γ τ} -> vsnd < v , w >v ⇓ w
    rsndnev : forall {Γ σ τ}{n : NeV Γ (σ × τ)} -> vsnd nev n ⇓ nev (sndV n) 
           
  data _$$_⇓_ : forall {Γ σ τ} -> 
                Val Γ (σ ⇒ τ) -> Val Γ σ -> Val Γ τ -> Set where
    r$lam : forall {Γ Δ σ τ}{t : Tm (Δ < σ) τ}{vs : Env Γ Δ}{a : Val Γ σ}{v} ->
            eval t & vs << a ⇓ v -> λv t vs $$ a ⇓ v
    r$ne  : forall {Γ σ τ}{n : NeV Γ (σ ⇒ τ)}{v : Val Γ σ} ->
            nev n $$ v ⇓ nev (appV n v)

  data evalˢ_&_⇓_ : forall {Γ Δ Σ} -> 
                    Sub Δ Σ -> Env Γ Δ -> Env Γ Σ -> Set where
    rˢpop  : forall {Γ Δ σ}{vs : Env Γ Δ}{v : Val Γ σ} -> 
             evalˢ pop σ & vs << v ⇓ vs
    rˢcons : forall {Γ Δ Σ σ}{ts : Sub Δ Σ}{t : Tm Δ σ}{vs : Env Γ Δ}{ws v} ->
             evalˢ ts & vs ⇓ ws -> eval t & vs ⇓ v -> 
             evalˢ ts < t & vs ⇓ (ws << v)
    rˢid   : forall {Γ Δ}{vs : Env Γ Δ} -> evalˢ id & vs ⇓ vs
    rˢcomp : forall {A B Γ Δ}{ts : Sub Γ Δ}{us : Sub B Γ}{vs : Env A B}{ws}
                    {xs} -> evalˢ us & vs ⇓ ws ->
                    evalˢ ts & ws ⇓ xs -> evalˢ ts ○ us & vs ⇓ xs

mutual
  data quot_⇓_ : forall {Γ σ} -> Val Γ σ -> Nf Γ σ -> Set where
    qbase : forall {Γ}{m : NeV Γ ι}{n} -> quotⁿ m ⇓ n -> quot nev m ⇓ neι n
    qarr  : forall {Γ σ τ}{f : Val Γ (σ ⇒ τ)}{v : Val (Γ < σ) τ}{n} ->
            vwk σ f $$ nev (varV vZ) ⇓ v ->  quot v ⇓ n -> quot f ⇓ λn n
    qNz   : forall {Γ} -> quot zerov {Γ} ⇓ zeron
    qNs   : forall {Γ}{v : Val Γ N}{n : Nf Γ N} -> quot v ⇓ n ->
            quot sucv v ⇓ sucn n 
    qNn   : forall {Γ}{n : NeV Γ N}{n' : NeN Γ N} -> quotⁿ n ⇓ n' ->
            quot nev n ⇓ neN n'
    qone   : forall {Γ}{v : Val Γ One} -> quot v ⇓ voidn
    qprod  : forall {Γ σ τ}{p : Val Γ (σ × τ)}
             {v : Val Γ σ} -> vfst p ⇓ v -> {m : Nf Γ σ} -> quot v ⇓ m ->
             {w : Val Γ τ} -> vsnd p ⇓ w -> {n : Nf Γ τ} -> quot w ⇓ n ->
             quot p ⇓ < m , n >n

  data quotⁿ_⇓_ : forall {Γ σ} -> NeV Γ σ -> NeN Γ σ -> Set where
    qⁿvar  : forall {Γ σ}{x : Var Γ σ} -> quotⁿ varV x ⇓ varN x
    qⁿapp  : forall {Γ σ τ}{m : NeV Γ (σ ⇒ τ)}{v}{n}{n'} ->
             quotⁿ m ⇓ n -> quot v ⇓ n' -> quotⁿ appV m v ⇓ appN n n'
    qⁿprim : forall {Γ σ}{z : Val Γ σ}{s n z' s' n'} -> quot z ⇓ z' ->
             quot s ⇓ s' -> quotⁿ n ⇓ n' -> 
             quotⁿ primV z s n ⇓ primN z' s' n'
    qⁿfst : forall {Γ σ τ}{m : NeV Γ (σ × τ)}{n : NeN Γ (σ × τ)} ->
            quotⁿ m ⇓ n -> quotⁿ fstV m ⇓ fstN n
    qⁿsnd : forall {Γ σ τ}{m : NeV Γ (σ × τ)}{n : NeN Γ (σ × τ)} ->
            quotⁿ m ⇓ n -> quotⁿ sndV m ⇓ sndN n

open import FullSystem.IdentityEnvironment

data nf_⇓_ {Γ : Con}{σ : Ty} : Tm Γ σ -> Nf Γ σ -> Set where
  norm⇓ : forall {t v n} -> eval t & vid ⇓ v -> quot v ⇓ n -> nf t ⇓ n
