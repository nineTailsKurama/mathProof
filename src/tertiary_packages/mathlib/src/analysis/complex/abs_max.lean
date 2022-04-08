/-
Copyright (c) 2022 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov
-/
import analysis.complex.cauchy_integral
import analysis.convex.integral
import analysis.normed_space.completion
import topology.algebra.order.extr_closure

/-!
# Maximum modulus principle

In this file we prove several versions of the maximum modulus principle.

There are several statements that can be called "the maximum modulus principle" for maps between
normed complex spaces.

In the most general case, see `complex.norm_eventually_eq_of_is_local_max`, we can only say that for
a differentiable function `f : E → F`, if the norm has a local maximum at `z`, then *the norm* is
constant in a neighborhood of `z`.

If the domain is a nontrivial finite dimensional space, then this implies the following version of
the maximum modulus principle, see `complex.exists_mem_frontier_is_max_on_norm`. If `f : E → F` is
complex differentiable on a nonempty compact set `K`, then there exists a point `z ∈ frontier K`
such that `λ z, ∥f z∥` takes it maximum value on `K` at `z`.

Finally, if the codomain is a strictly convex space, then the function cannot have a local maximum
of the norm unless the function (not only its norm) is a constant. This version is not formalized
yet.
-/

open topological_space metric set filter asymptotics function measure_theory affine_map
open_locale topological_space filter nnreal real

universes u v w
variables {E : Type u} [normed_group E] [normed_space ℂ E]
  {F : Type v} [normed_group F] [normed_space ℂ F]

local postfix `̂`:100 := uniform_space.completion

namespace complex

/-!
### Auxiliary lemmas

We split the proof into a series of lemmas. First we prove the principle for a function `f : ℂ → F`
with an additional assumption that `F` is a complete space, then drop unneeded assumptions one by
one.

The only "public API" lemmas in this section are TODO and
`complex.norm_eq_norm_of_is_max_on_of_closed_ball_subset`.
-/

lemma norm_max_aux₁ [complete_space F] {f : ℂ → F} {z w : ℂ}
  (hd : diff_on_int_cont ℂ f (closed_ball z (dist w z)))
  (hz : is_max_on (norm ∘ f) (closed_ball z (dist w z)) z) :
  ∥f w∥ = ∥f z∥ :=
begin
  /- Consider a circle of radius `r = dist w z`. -/
  set r : ℝ := dist w z,
  have hw : w ∈ closed_ball z r, from mem_closed_ball.2 le_rfl,
  /- Assume the converse. Since `∥f w∥ ≤ ∥f z∥`, we have `∥f w∥ < ∥f z∥`. -/
  refine (is_max_on_iff.1 hz _ hw).antisymm (not_lt.1 _),
  rintro hw_lt : ∥f w∥ < ∥f z∥,
  have hr : 0 < r, from dist_pos.2 (ne_of_apply_ne (norm ∘ f) hw_lt.ne),
  /- Due to Cauchy integral formula, it suffices to prove the following inequality. -/
  suffices : ∥∮ ζ in C(z, r), (ζ - z)⁻¹ • f ζ∥ < 2 * π * ∥f z∥,
  { refine this.ne _,
    have A : ∮ ζ in C(z, r), (ζ - z)⁻¹ • f ζ = (2 * π * I : ℂ) • f z :=
      hd.circle_integral_sub_inv_smul (mem_ball_self hr),
    simp [A, norm_smul, real.pi_pos.le] },
  suffices : ∥∮ ζ in C(z, r), (ζ - z)⁻¹ • f ζ∥ < 2 * π * r * (∥f z∥ / r),
    by rwa [mul_assoc, mul_div_cancel' _ hr.ne'] at this,
  /- This inequality is true because `∥(ζ - z)⁻¹ • f ζ∥ ≤ ∥f z∥ / r` for all `ζ` on the circle and
  this inequality is strict at `ζ = w`. -/
  have hsub : sphere z r ⊆ closed_ball z r, from sphere_subset_closed_ball,
  refine circle_integral.norm_integral_lt_of_norm_le_const_of_lt hr _ _ ⟨w, rfl, _⟩,
  show continuous_on (λ (ζ : ℂ), (ζ - z)⁻¹ • f ζ) (sphere z r),
  { refine ((continuous_on_id.sub continuous_on_const).inv₀ _).smul (hd.continuous_on.mono hsub),
    exact λ ζ hζ, sub_ne_zero.2 (ne_of_mem_sphere hζ hr.ne') },
  show ∀ ζ ∈ sphere z r, ∥(ζ - z)⁻¹ • f ζ∥ ≤ ∥f z∥ / r,
  { rintros ζ (hζ : abs (ζ - z) = r),
    rw [le_div_iff hr, norm_smul, norm_inv, norm_eq_abs, hζ, mul_comm, mul_inv_cancel_left₀ hr.ne'],
    exact hz (hsub hζ) },
  show ∥(w - z)⁻¹ • f w∥ < ∥f z∥ / r,
  { rw [norm_smul, norm_inv, norm_eq_abs, ← div_eq_inv_mul],
    exact (div_lt_div_right hr).2 hw_lt }
end

/-!
Now we drop the assumption `complete_space F` by embedding `F` into its completion.
-/

lemma norm_max_aux₂ {f : ℂ → F} {z w : ℂ} (hd : diff_on_int_cont ℂ f (closed_ball z (dist w z)))
  (hz : is_max_on (norm ∘ f) (closed_ball z (dist w z)) z) :
  ∥f w∥ = ∥f z∥ :=
begin
  set e : F →L[ℂ] F̂ := uniform_space.completion.to_complL,
  have he : ∀ x, ∥e x∥ = ∥x∥, from uniform_space.completion.norm_coe,
  replace hz : is_max_on (norm ∘ (e ∘ f)) (closed_ball z (dist w z)) z,
    by simpa only [is_max_on, (∘), he] using hz,
  simpa only [he] using norm_max_aux₁ (e.differentiable.comp_diff_on_int_cont hd) hz
end

/-!
Then we replace the assumption `is_max_on (norm ∘ f) (closed_ball z r) z` with a seemingly weaker
assumption `is_max_on (norm ∘ f) (ball z r) z`.
-/

lemma norm_max_aux₃ {f : ℂ → F} {z w : ℂ} {r : ℝ} (hr : dist w z = r)
  (hd : diff_on_int_cont ℂ f (closed_ball z r)) (hz : is_max_on (norm ∘ f) (ball z r) z) :
  ∥f w∥ = ∥f z∥ :=
begin
  subst r,
  rcases eq_or_ne w z with rfl|hne, { refl },
  have : closure (ball z (dist w z)) = closed_ball z (dist w z),
    from closure_ball z (dist_ne_zero.2 hne),
  exact norm_max_aux₂ hd (this ▸ hz.closure (this.symm ▸ hd.continuous_on.norm))
end

/-!
Finally, we generalize the theorem from a disk in `ℂ` to a closed ball in any normed space.
-/

/-- **Maximum modulus principle** on a closed ball: if `f : E → F` is continuous on a closed ball,
is complex differentiable on the corresponding open ball, and the norm `∥f w∥` takes its maximum
value on the open ball at its center, then the norm `∥f w∥` is constant on the closed ball.  -/
lemma norm_eq_on_closed_ball_of_is_max_on {f : E → F} {z : E} {r : ℝ}
  (hd : diff_on_int_cont ℂ f (closed_ball z r)) (hz : is_max_on (norm ∘ f) (ball z r) z) :
  eq_on (norm ∘ f) (const E ∥f z∥) (closed_ball z r) :=
begin
  intros w hw,
  rw [mem_closed_ball, dist_comm] at hw,
  rcases eq_or_ne z w with rfl|hne, { refl },
  set e : ℂ → E := line_map z w,
  have hde : differentiable ℂ e := (differentiable_id.smul_const (w - z)).add_const z,
  suffices : ∥(f ∘ e) (1 : ℂ)∥ = ∥(f ∘ e) (0 : ℂ)∥, by simpa [e],
  have hr : dist (1 : ℂ) 0 = 1, by simp,
  have hball : maps_to e (ball 0 1) (ball z r),
  { refine ((lipschitz_with_line_map z w).maps_to_ball
      (mt nndist_eq_zero.1 hne) 0 1).mono subset.rfl _,
    simpa only [line_map_apply_zero, mul_one, coe_nndist] using ball_subset_ball hw },
  refine norm_max_aux₃ hr (diff_on_int_cont.mk_ball
    (hd.differentiable_on_ball.comp hde.differentiable_on hball)
    (hd.continuous_on.comp hde.continuous.continuous_on _)) _,
  { refine ((lipschitz_with_line_map z w).maps_to_closed_ball 0 1).mono_right _,
    simpa only [line_map_apply_zero, mul_one, coe_nndist] using closed_ball_subset_closed_ball hw },
  { exact hz.comp_maps_to hball (line_map_apply_zero z w) }
end

/-!
### Different forms of the maximum modulus principle
-/

/-- **Maximum modulus principle**: if `f : E → F` is complex differentiable on a set `s`, the norm
of `f` takes it maximum on `s` at `z` and `w` is a point such that the closed ball with center `z`
and radius `dist w z` is included in `s`, then `∥f w∥ = ∥f z∥`. -/
lemma norm_eq_norm_of_is_max_on_of_closed_ball_subset {f : E → F} {s : set E} {z w : E}
  (hd : diff_on_int_cont ℂ f s) (hz : is_max_on (norm ∘ f) s z)
  (hsub : closed_ball z (dist w z) ⊆ s) :
  ∥f w∥ = ∥f z∥ :=
norm_eq_on_closed_ball_of_is_max_on (hd.mono hsub)
  (hz.on_subset $ ball_subset_closed_ball.trans hsub) (mem_closed_ball.2 le_rfl)

/-- **Maximum modulus principle**: if `f : E → F` is complex differentiable in a neighborhood of `c`
and the norm `∥f z∥` has a local maximum at `c`, then `∥f z∥` is locally constant in a neighborhood
of `c`. -/
lemma norm_eventually_eq_of_is_local_max {f : E → F} {c : E}
  (hd : ∀ᶠ z in 𝓝 c, differentiable_at ℂ f z) (hc : is_local_max (norm ∘ f) c) :
  ∀ᶠ y in 𝓝 c, ∥f y∥ = ∥f c∥ :=
begin
  rcases nhds_basis_closed_ball.eventually_iff.1 (hd.and hc) with ⟨r, hr₀, hr⟩,
  exact nhds_basis_closed_ball.eventually_iff.2 ⟨r, hr₀, norm_eq_on_closed_ball_of_is_max_on
    (differentiable_on.diff_on_int_cont $ λ x hx, (hr hx).1.differentiable_within_at) $
    λ x hx, (hr $ ball_subset_closed_ball hx).2⟩
end

lemma is_open_set_of_mem_nhds_and_is_max_on_norm {f : E → F} {s : set E}
  (hd : differentiable_on ℂ f s) :
  is_open {z | s ∈ 𝓝 z ∧ is_max_on (norm ∘ f) s z} :=
begin
  refine is_open_iff_mem_nhds.2 (λ z hz, (eventually_eventually_nhds.2 hz.1).and _),
  replace hd : ∀ᶠ w in 𝓝 z, differentiable_at ℂ f w, from hd.eventually_differentiable_at hz.1,
  exact (norm_eventually_eq_of_is_local_max hd $ (hz.2.is_local_max hz.1)).mono
    (λ x hx y hy, le_trans (hz.2 hy) hx.ge)
end

/-- **Maximum modulus principle**: if `f : E → F` is complex differentiable on a nonempty compact
set `K`, then there exists a point `z ∈ frontier K` such that `λ z, ∥f z∥` takes it maximum value on
`K` at `z`. -/
lemma exists_mem_frontier_is_max_on_norm [nontrivial E] {f : E → F} {K : set E} (hK : is_compact K)
  (hne : K.nonempty) (hd : diff_on_int_cont ℂ f K) :
  ∃ z ∈ frontier K, is_max_on (norm ∘ f) K z :=
begin
  rcases hK.exists_forall_ge hne hd.continuous_on.norm with ⟨w, hwK, hle⟩,
  rcases hK.exists_mem_frontier_inf_dist_compl_eq_dist hwK with ⟨z, hzK, hzw⟩,
  refine ⟨z, hzK, λ x hx, (hle x hx).trans_eq _⟩,
  refine (norm_eq_norm_of_is_max_on_of_closed_ball_subset hd hle _).symm,
  calc closed_ball w (dist z w) = closed_ball w (inf_dist w Kᶜ) : by rw [hzw, dist_comm]
  ... ⊆ closure K : closed_ball_inf_dist_compl_subset_closure hwK
  ... = K : hK.is_closed.closure_eq
end

/-- **Maximum modulus principle**: if `f : E → F` is complex differentiable on a compact set `K` and
`∥f z∥ ≤ C` for any `z ∈ frontier K`, then the same is true for any `z ∈ K`. -/
lemma norm_le_of_forall_mem_frontier_norm_le [nontrivial E] {f : E → F} {K : set E}
  (hK : is_compact K) (hd : diff_on_int_cont ℂ f K)
  {C : ℝ} (hC : ∀ z ∈ frontier K, ∥f z∥ ≤ C) {z : E} (hz : z ∈ K) :
  ∥f z∥ ≤ C :=
let ⟨w, hwK, hw⟩ := exists_mem_frontier_is_max_on_norm hK ⟨z, hz⟩ hd
in le_trans (hw hz) (hC w hwK)

/-- If two complex differentiable functions `f g : E → F` are equal on the boundary of a compact set
`K`, then they are equal on `K`. -/
lemma eq_on_of_eq_on_frontier [nontrivial E] {f g : E → F} {K : set E} (hK : is_compact K)
  (hf : diff_on_int_cont ℂ f K) (hg : diff_on_int_cont ℂ g K) (hfg : eq_on f g (frontier K)) :
  eq_on f g K :=
begin
  suffices H : ∀ z ∈ K, ∥f z - g z∥ ≤ 0, by simpa [sub_eq_zero] using H,
  convert λ z hz, norm_le_of_forall_mem_frontier_norm_le hK (hf.sub hg) _ hz,
  simpa [sub_eq_zero]
end

end complex
