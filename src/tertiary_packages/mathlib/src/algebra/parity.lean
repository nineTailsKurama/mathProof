/-
Copyright (c) 2022 Damiano Testa. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Damiano Testa
-/

import algebra.ring.basic
import algebra.algebra.basic
import algebra.group_power.basic
import algebra.field_power
import algebra.opposites

/-!  # Squares, even and odd elements

This file proves some general facts about squares, even and odd elements of semirings.

In the implementation, we define `is_square` and we let `even` be the notion transported by
`to_additive`.  The definition are therefore as follows:
```lean
is_square a ↔ ∃ r, a = r * r
even a ↔ ∃ r, a = r + r
```

Odd elements are not unified with a multiplicative notion.

## Future work

* TODO: Try to generalize further the typeclass assumptions on `is_square/even`.
  For instance, in some cases, there are `semiring` assumptions that I (DT) am not convinced are
  necessary.
* TODO: Consider moving the definition and lemmas about `odd` to a separate file.
* TODO: The "old" definition of `even a` asked for the existence of an element `c` such that
  `a = 2 * c`.  For this reason, several fixes introduce an extra `two_mul` or `← two_mul`.
  It might be the case that by making a careful choice of `simp` lemma, this can be avoided.
 -/

open mul_opposite
variables {α β : Type*}

/--  An element `a` of a type `α` with multiplication satisfies `square a` if `a = r * r`,
for some `r : α`. -/
@[to_additive
"An element `a` of a type `α` with addition satisfies `even a` if `a = r + r`,
for some `r : α`."]
def is_square [has_mul α] (a : α) : Prop := ∃ r, a = r * r

@[simp, to_additive]
lemma is_square_mul_self [has_mul α] (m : α) : is_square (m * m) := ⟨m, rfl⟩

@[to_additive even_iff_exists_two_nsmul]
lemma is_square_iff_exists_sq [monoid α] (m : α) : is_square m ↔ ∃ c, m = c ^ 2 :=
by simp [is_square, pow_two]

alias is_square_iff_exists_sq ↔ is_square.exists_sq is_square_of_exists_sq

attribute [to_additive even.exists_two_nsmul] is_square.exists_sq
/-- Alias of the forwards direction of `even_iff_exists_two_nsmul`. -/
add_decl_doc even.exists_two_nsmul

attribute [to_additive even_of_exists_two_nsmul] is_square_of_exists_sq
/-- Alias of the backwards direction of `even_iff_exists_two_nsmul`. -/
add_decl_doc even_of_exists_two_nsmul

@[simp, to_additive even_two_nsmul]
lemma is_square_sq [monoid α] (a : α) : is_square (a ^ 2) := ⟨a, pow_two _⟩

@[simp, to_additive]
lemma is_square_one [mul_one_class α] : is_square (1 : α) := ⟨1, (mul_one _).symm⟩

@[to_additive]
lemma is_square.map {F : Type*} [mul_one_class α] [mul_one_class β] [monoid_hom_class F α β]
  {m : α} (f : F) (hm : is_square m) :
  is_square (f m) :=
begin
  rcases hm with ⟨m, rfl⟩,
  exact ⟨f m, by simp⟩
end

@[to_additive]
lemma is_square.mul_is_square [comm_monoid α] {m n : α} (hm : is_square m) (hn : is_square n) :
  is_square (m * n) :=
begin
  rcases hm with ⟨m, rfl⟩,
  rcases hn with ⟨n, rfl⟩,
  refine ⟨m * n, mul_mul_mul_comm m m n n⟩,
end

section group
variable [group α]

@[to_additive]
lemma is_square_op_iff (a : α) : is_square (op a) ↔ is_square a :=
⟨λ ⟨c, hc⟩, ⟨unop c, by rw [← unop_mul, ← hc, unop_op]⟩, λ ⟨c, hc⟩, by simp [hc]⟩

@[simp, to_additive] lemma is_square_inv (a : α) : is_square a⁻¹ ↔ is_square a :=
begin
  refine ⟨λ h, _, λ h, _⟩,
  { rw [← is_square_op_iff, ← inv_inv a],
    exact h.map (mul_equiv.inv' α) },
  { exact ((is_square_op_iff a).mpr h).map (mul_equiv.inv' α).symm }
end

end group

section comm_group
variable [comm_group α]

@[to_additive]
lemma is_square.div_is_square {m n : α} (hm : is_square m) (hn : is_square n) : is_square (m / n) :=
by { rw div_eq_mul_inv,  exact hm.mul_is_square ((is_square_inv n).mpr hn) }

end comm_group

section semiring
variables [semiring α] [semiring β] {m n : α}

lemma even_iff_exists_two_mul (m : α) : even m ↔ ∃ c, m = 2 * c :=
by simp [even_iff_exists_two_nsmul]

lemma even_iff_two_dvd {a : α} : even a ↔ 2 ∣ a := by simp [even, has_dvd.dvd, two_mul]

@[simp] lemma range_two_mul (α : Type*) [semiring α] :
  set.range (λ x : α, 2 * x) = {a | even a} :=
by { ext x, simp [eq_comm, two_mul, even] }

@[simp] lemma even_bit0 (a : α) : even (bit0 a) :=
⟨a, rfl⟩

@[simp] lemma even_two : even (2 : α) := ⟨1, rfl⟩

@[simp] lemma even.mul_left (hm : even m) (n) : even (n * m) :=
hm.map (add_monoid_hom.mul_left n)

@[simp] lemma even.mul_right (hm : even m) (n) : even (m * n) :=
hm.map (add_monoid_hom.mul_right n)

lemma even_two_mul (m : α) : even (2 * m) := ⟨m, two_mul _⟩

lemma even.pow_of_ne_zero (hm : even m) : ∀ {a : ℕ}, a ≠ 0 → even (m ^ a)
| 0       a0 := (a0 rfl).elim
| (a + 1) _  := by { rw pow_succ, exact hm.mul_right _ }

section with_odd

/-- An element `a` of a semiring is odd if there exists `k` such `a = 2*k + 1`. -/
def odd (a : α) : Prop := ∃ k, a = 2*k + 1

@[simp] lemma odd_bit1 (a : α) : odd (bit1 a) :=
⟨a, by rw [bit1, bit0, two_mul]⟩

@[simp] lemma range_two_mul_add_one (α : Type*) [semiring α] :
  set.range (λ x : α, 2 * x + 1) = {a | odd a} :=
by { ext x, simp [odd, eq_comm] }

lemma even.add_odd (hm : even m) (hn : odd n) : odd (m + n) :=
begin
  rcases hm with ⟨m, rfl⟩,
  rcases hn with ⟨n, rfl⟩,
  exact ⟨m + n, by rw [mul_add, ← two_mul, add_assoc]⟩
end

lemma odd.add_even (hm : odd m) (hn : even n) : odd (m + n) :=
by { rw add_comm, exact hn.add_odd hm }

lemma odd.add_odd (hm : odd m) (hn : odd n) : even (m + n) :=
begin
  rcases hm with ⟨m, rfl⟩,
  rcases hn with ⟨n, rfl⟩,
  refine ⟨n + m + 1, _⟩,
  rw [← two_mul, ←add_assoc, add_comm _ (2 * n), ←add_assoc, ←mul_add, add_assoc, mul_add _ (n + m),
    mul_one],
  refl
end

@[simp] lemma odd_one : odd (1 : α) :=
⟨0, (zero_add _).symm.trans (congr_arg (+ (1 : α)) (mul_zero _).symm)⟩

@[simp] lemma odd_two_mul_add_one (m : α) : odd (2 * m + 1) := ⟨m, rfl⟩

lemma ring_hom.odd (f : α →+* β) (hm : odd m) : odd (f m) :=
begin
  rcases hm with ⟨m, rfl⟩,
  exact ⟨f m, by simp [two_mul]⟩
end

@[simp] lemma odd.mul_odd (hm : odd m) (hn : odd n) : odd (m * n) :=
begin
  rcases hm with ⟨m, rfl⟩,
  rcases hn with ⟨n, rfl⟩,
  refine ⟨2 * m * n + n + m, _⟩,
  rw [mul_add, add_mul, mul_one, ← add_assoc, one_mul, mul_assoc, ← mul_add, ← mul_add, ← mul_assoc,
    ← nat.cast_two, ← nat.cast_comm],
end

lemma odd.pow (hm : odd m) : ∀ {a : ℕ}, odd (m ^ a)
| 0       := by { rw pow_zero, exact odd_one }
| (a + 1) := by { rw pow_succ, exact hm.mul_odd odd.pow }

end with_odd

end semiring

section ring
variables [ring α] {m n : α}

@[simp] lemma even_neg_two : even (- 2 : α) := by simp only [even_neg, even_two]

lemma even_abs [linear_order α] {a : α} : even (|a|) ↔ even a :=
begin
  rcases abs_choice a with h | h; rw h,
  exact even_neg a,
end

lemma odd.neg {a : α} (hp : odd a) : odd (-a) :=
begin
  obtain ⟨k, hk⟩ := hp,
  use -(k + 1),
  rw [mul_neg, mul_add, neg_add, add_assoc, two_mul (1 : α), neg_add,
    neg_add_cancel_right, ←neg_add, hk],
end

@[simp] lemma odd_neg (a : α) : odd (-a) ↔ odd a :=
⟨λ h, neg_neg a ▸ h.neg, odd.neg⟩

@[simp] lemma odd_neg_one : odd (- 1 : α) := by simp

theorem odd.sub_even (hm : odd m) (hn : even n) : odd (m - n) :=
by { rw sub_eq_add_neg, exact hm.add_even ((even_neg n).mpr hn) }

theorem even.sub_odd (hm : even m) (hn : odd n) : odd (m - n) :=
by { rw sub_eq_add_neg, exact hm.add_odd ((odd_neg n).mpr hn) }

lemma odd.sub_odd (hm : odd m) (hn : odd n) : even (m - n) :=
by { rw sub_eq_add_neg, exact hm.add_odd ((odd_neg n).mpr hn) }

lemma odd_abs [linear_order α] {a : α} : odd (abs a) ↔ odd a :=
by { cases abs_choice a with h h; simp only [h, odd_neg] }

end ring

section powers
variables {R : Type*}
  {a : R} {n : ℕ} [linear_ordered_ring R]

lemma even.pow_nonneg (hn : even n) (a : R) : 0 ≤ a ^ n :=
by cases hn with k hk; simpa only [hk, two_mul] using pow_bit0_nonneg a k

lemma even.pow_pos (hn : even n) (ha : a ≠ 0) : 0 < a ^ n :=
by cases hn with k hk; simpa only [hk, two_mul] using pow_bit0_pos ha k

lemma odd.pow_nonpos (hn : odd n) (ha : a ≤ 0) : a ^ n ≤ 0:=
by cases hn with k hk; simpa only [hk, two_mul] using pow_bit1_nonpos_iff.mpr ha

lemma odd.pow_neg (hn : odd n) (ha : a < 0) : a ^ n < 0:=
by cases hn with k hk; simpa only [hk, two_mul] using pow_bit1_neg_iff.mpr ha

lemma odd.pow_nonneg_iff (hn : odd n) : 0 ≤ a ^ n ↔ 0 ≤ a :=
⟨λ h, le_of_not_lt (λ ha, h.not_lt $ hn.pow_neg ha), λ ha, pow_nonneg ha n⟩

lemma odd.pow_nonpos_iff (hn : odd n) : a ^ n ≤ 0 ↔ a ≤ 0 :=
⟨λ h, le_of_not_lt (λ ha, h.not_lt $ pow_pos ha _), hn.pow_nonpos⟩

lemma odd.pow_pos_iff (hn : odd n) : 0 < a ^ n ↔ 0 < a :=
⟨λ h, lt_of_not_ge' (λ ha, h.not_le $ hn.pow_nonpos ha), λ ha, pow_pos ha n⟩

lemma odd.pow_neg_iff (hn : odd n) : a ^ n < 0 ↔ a < 0 :=
⟨λ h, lt_of_not_ge' (λ ha, h.not_le $ pow_nonneg ha _), hn.pow_neg⟩

lemma even.pow_pos_iff (hn : even n) (h₀ : 0 < n) : 0 < a ^ n ↔ a ≠ 0 :=
⟨λ h ha, by { rw [ha, zero_pow h₀] at h, exact lt_irrefl 0 h }, hn.pow_pos⟩

lemma even.pow_abs {p : ℕ} (hp : even p) (a : R) : |a| ^ p = a ^ p :=
begin
  rw [←abs_pow, abs_eq_self],
  exact hp.pow_nonneg _
end

@[simp] lemma pow_bit0_abs (a : R) (p : ℕ) : |a| ^ bit0 p = a ^ bit0 p := (even_bit0 _).pow_abs _

lemma odd.strict_mono_pow (hn : odd n) : strict_mono (λ a : R, a ^ n) :=
by cases hn with k hk; simpa only [hk, two_mul] using strict_mono_pow_bit1 _

end powers

/-- The cardinality of `fin (bit0 k)` is even, `fact` version.
This `fact` is needed as an instance by `matrix.special_linear_group.has_neg`. -/
lemma fintype.card_fin_even {k : ℕ} : fact (even (fintype.card (fin (bit0 k)))) :=
⟨by { rw [fintype.card_fin], exact even_bit0 k }⟩

section field_power
variable {K : Type*}

lemma even.zpow_neg [division_ring K] {n : ℤ} (h : even n) (a : K) :
  (-a) ^ n = a ^ n :=
begin
  obtain ⟨k, rfl⟩ := h,
  rw [← two_mul, ←bit0_eq_two_mul, zpow_bit0_neg],
end

variables [linear_ordered_field K] {n : ℤ} {a : K}

lemma even.zpow_nonneg (hn : even n) (a : K) :
  0 ≤ a ^ n :=
begin
  cases le_or_lt 0 a with h h,
  { exact zpow_nonneg h _ },
  { exact (hn.zpow_neg a).subst (zpow_nonneg (neg_nonneg_of_nonpos h.le) _) }
end

theorem even.zpow_pos (hn : even n) (ha : a ≠ 0) : 0 < a ^ n :=
by cases hn with k hk; simpa only [hk, two_mul] using zpow_bit0_pos ha k

theorem odd.zpow_nonneg (hn : odd n) (ha : 0 ≤ a) : 0 ≤ a ^ n :=
by cases hn with k hk; simpa only [hk, two_mul] using zpow_bit1_nonneg_iff.mpr ha

theorem odd.zpow_pos (hn : odd n) (ha : 0 < a) : 0 < a ^ n :=
by cases hn with k hk; simpa only [hk, two_mul] using zpow_bit1_pos_iff.mpr ha

theorem odd.zpow_nonpos (hn : odd n) (ha : a ≤ 0) : a ^ n ≤ 0:=
by cases hn with k hk; simpa only [hk, two_mul] using zpow_bit1_nonpos_iff.mpr ha

theorem odd.zpow_neg (hn : odd n) (ha : a < 0) : a ^ n < 0:=
by cases hn with k hk; simpa only [hk, two_mul] using zpow_bit1_neg_iff.mpr ha

lemma even.zpow_abs {p : ℤ} (hp : even p) (a : K) : |a| ^ p = a ^ p :=
begin
  cases abs_choice a with h h;
  simp only [h, hp.zpow_neg _],
end

@[simp] lemma zpow_bit0_abs (a : K) (p : ℤ) : |a| ^ bit0 p = a ^ bit0 p :=
(even_bit0 _).zpow_abs _

lemma even.abs_zpow {p : ℤ} (hp : even p) (a : K) : |a ^ p| = a ^ p :=
begin
  rw [abs_eq_self],
  exact hp.zpow_nonneg _
end

@[simp] lemma abs_zpow_bit0 (a : K) (p : ℤ) :
  |a ^ bit0 p| = a ^ bit0 p :=
(even_bit0 _).abs_zpow _

end field_power
