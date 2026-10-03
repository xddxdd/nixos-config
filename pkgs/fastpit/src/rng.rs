//! `Xoshiro256++` random number generator and the FNV-1a hash used for seeding.

use std::hash::Hasher;

use fnv::FnvHasher;
use rand::seq::IndexedRandom;
use rand::{Rng as _, RngCore, SeedableRng};
use rand_xoshiro::Xoshiro256PlusPlus;

pub fn fnv1a64(bytes: &[u8]) -> u64 {
    let mut hasher = FnvHasher::default();
    hasher.write(bytes);
    hasher.finish()
}

pub struct Rng {
    inner: Xoshiro256PlusPlus,
}

impl Rng {
    pub fn new(seed: u64) -> Rng {
        Rng {
            inner: Xoshiro256PlusPlus::seed_from_u64(seed),
        }
    }

    #[allow(dead_code)]
    pub fn next_u64(&mut self) -> u64 {
        self.inner.next_u64()
    }

    pub fn below(&mut self, n: u64) -> u64 {
        assert!(n > 0, "Rng::below requires n > 0");
        self.inner.random_range(0..n)
    }

    pub fn range_inc(&mut self, lo: i64, hi: i64) -> i64 {
        debug_assert!(hi >= lo);
        self.inner.random_range(lo..=hi)
    }

    pub fn usize(&mut self, lo: usize, hi_excl: usize) -> usize {
        if hi_excl <= lo {
            return lo;
        }
        lo + self.below((hi_excl - lo) as u64) as usize
    }

    pub fn choice<'a, T>(&mut self, items: &'a [T]) -> Option<&'a T> {
        items.choose(&mut self.inner)
    }

    pub fn boolean(&mut self) -> bool {
        self.inner.random_bool(0.5)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn fnv1a_known_values() {
        assert_eq!(fnv1a64(b""), 0xcbf2_9ce4_8422_2325);
        assert_eq!(fnv1a64(b"hello"), 0xa430_d846_80aa_bd0b);
    }

    #[test]
    fn same_seed_same_sequence() {
        let mut a = Rng::new(42);
        let mut b = Rng::new(42);
        for _ in 0..64 {
            assert_eq!(a.next_u64(), b.next_u64());
        }
    }

    #[test]
    fn different_seeds_differ() {
        let mut a = Rng::new(1);
        let mut b = Rng::new(2);
        let sa: Vec<u64> = (0..8).map(|_| a.next_u64()).collect();
        let sb: Vec<u64> = (0..8).map(|_| b.next_u64()).collect();
        assert_ne!(sa, sb);
    }

    #[test]
    fn below_in_range() {
        let mut rng = Rng::new(7);
        for n in 1..=64u64 {
            for _ in 0..32 {
                assert!(rng.below(n) < n);
            }
        }
    }

    #[test]
    fn choice_single_element() {
        let mut rng = Rng::new(9);
        let items = ["only"];
        assert_eq!(rng.choice(&items), Some(&"only"));
        let empty: [u8; 0] = [];
        assert_eq!(rng.choice(&empty), None);
    }
}
