# Overview of Modulo multiplication methods

def lower_d_bits(value: int, d: int) -> int:
    '''Extracts the lower d bits of the value.'''
    return value & ((1 << d) - 1)


def upper_d_bits(value: int, d: int) -> int:
    '''Extracts the upper d bits of the value and shifts them down by d.'''
    return (value >> d) & ((1 << d) - 1)


def to_montgomery(a, q, size):
    return (a * 2**size) % q


def montgomery_mul(a_, b_, q, R, size):
    reg_c = a_ * b_
    reg_tmp = lower_d_bits(reg_c, size)  # mod size
    reg_tmp = lower_d_bits(reg_tmp * R, size)  # mod size
    r = upper_d_bits(reg_c + reg_tmp * q, size)  # / size
    if r >= q:
        r -= q
    return r


def to_plantard(a, q, size):
    return (a * (-1) * 2**(2 * size)) % q


def plantard_mul(a_, b_, q, R, size):
    c = lower_d_bits(a_ * b_ * R, 2 * size)
    c = upper_d_bits(c, size) + 1
    r = upper_d_bits(c * q, size)
    return r


# Public constants for Montgomery and Plantard for 32b values

# Montgomery R constant for 32b values
R_mt = 4236238847
# Plantard R constant for 32b values
R_pl = 1732267787797143553


if __name__ == "__main__":
    q = 8380417
    size = 32  # = d

    a_orig = 0x004982ba
    b_orig = 0x001ef089

    r_orig = (a_orig * b_orig) % q

    #######################################################
    #######################################################
    # Montgomery Transformation
    # Input: a, b in [0,q[
    # Computes r = a*b * 2^(-d) mod q
    # constant R = (-q)^(-1) mod 2^d
    #######################################################
    #######################################################

    # check constraints
    assert a_orig < q**2
    assert b_orig < q**2

    # convert to montgomery space
    a_mt = (a_orig * 2**size) % q
    b_mt = (b_orig * 2**size) % q

    # Multiply 3 variants
    # r_mt: both are in MT space -> requires reduction
    # r_mt_orig: only b is in MT space -> does not require reduction
    # r_none: both are in original space -> does not work
    r_mt = montgomery_mul(a_mt, b_mt, q, R_mt, size)
    r_mt_orig = montgomery_mul(a_orig, b_mt, q, R_mt, size)
    r_none = montgomery_mul(a_orig, b_orig, q, R_mt, size)

    # convert r back to original space with reduction
    r_orig_from_mt = montgomery_mul(r_mt, 1, q, R_mt, size)
    r_mt_orig_from_mt = montgomery_mul(r_mt_orig, 1, q, R_mt, size)
    r_none_from_mt = montgomery_mul(r_none, 1, q, R_mt, size)

    print("Montgomery")
    print(f"Original Inputs (a < q**2, b < q**2)          : {a_orig}, {b_orig}")
    print(f"Original result   = a * b % q                 = {r_orig:10}")
    print(f"a_mt              = (a * 2**{size:2}) % q           = {a_mt:10}")
    print(f"b_mt              = (b * 2**{size:2}) % q           = {b_mt:10}")
    print(f"r_mt              = MontMul(a_mt, b_mt)       = {r_mt:10} -> " + ("ok" if r_orig == r_mt else "fail"))
    print(f"r_mt_orig         = MontMul(a_orig, b_mt)     = {r_mt_orig:10} -> " + ("ok" if r_orig == r_mt_orig else "fail"))
    print(f"r_none            = MontMul(a_orig, b_orig)   = {r_none:10} -> " + ("ok" if r_orig == r_none else "fail"))
    print(f"r_orig_from_mt    = MontMul(r_mt, 1)          = {r_orig_from_mt:10} -> " + ("ok" if r_orig == r_orig_from_mt else "fail"))
    print(f"r_mt_orig_from_mt = MontMul(r_orig_from_mt, 1)= {r_mt_orig_from_mt:10} -> " + ("ok" if r_orig == r_mt_orig_from_mt else "fail"))
    print(f"r_none_from_mt    = MontMul(r_none, 1)        = {r_none_from_mt:10} -> " + ("ok" if r_orig == r_none_from_mt else "fail"))

    #######################################################
    #######################################################
    # Plantard Transformation
    # Input: a, b in [0,q]
    # Computes r = a*b*(-(2^(-2d))) mod q
    # Constant R = q^(-1) mod 2^(2*d)
    #######################################################
    #######################################################

    # check constraints
    assert a_orig <= q
    assert b_orig <= q
    pl_phi = 1.618033989  # (1 + sqrt(5)) / 2
    assert q < ((2**size) / pl_phi)

    # convert to Plantard space
    a_pl = (a_orig * (-1) * 2**(2 * size)) % q
    b_pl = (b_orig * (-1) * 2**(2 * size)) % q

    # r_pl: both are in PL space -> requires reduction
    # r_pl_orig: only b is in PL space -> does not require reduction
    # r_none: both are in original space -> does not work
    r_pl = plantard_mul(a_pl, b_pl, q, R_pl, size)
    r_pl_orig = plantard_mul(a_orig, b_pl, q, R_pl, size)
    r_pl_none = plantard_mul(a_orig, b_orig, q, R_pl, size)

    # convert back to original space with reduction
    r_pl_from_pl = plantard_mul(r_pl, 1, q, R_pl, size)
    r_pl_orig_from_pl = plantard_mul(r_pl_orig, 1, q, R_pl, size)
    r_pl_none_from_pl = plantard_mul(r_pl_none, 1, q, R_pl, size)

    print("\nPlantard")
    print(f"Original Inputs (a <= q, b <= q)                 : {a_orig}, {b_orig}")
    print(f"Original result   = a * b % q                    = {r_orig:10}")
    print(f"a_pl              = (a * 2**{size:2}) % q              = {a_pl:10}")
    print(f"b_pl              = (b * 2**{size:2}) % q              = {b_pl:10}")
    print(f"r_pl              = PlanMul(a_mt, b_mt)          = {r_pl:10} -> " + ("ok" if r_orig == r_pl else "fail"))
    print(f"r_pl_orig         = PlanMul(a_orig, b_mt)        = {r_pl_orig:10} -> " + ("ok" if r_orig == r_pl_orig else "fail"))
    print(f"r_pl_none         = PlanMul(a_orig, b_orig)      = {r_pl_none:10} -> " + ("ok" if r_orig == r_pl_none else "fail"))
    print(f"r_pl_from_pl      = PlanMul(r_mt, 1)             = {r_pl_from_pl:10} -> " + ("ok" if r_orig == r_pl_from_pl else "fail"))
    print(f"r_pl_orig_from_pl = PlanMul(r_pl_orig, 1)        = {r_pl_orig_from_pl:10} -> " + ("ok" if r_orig == r_pl_orig_from_pl else "fail"))
    print(f"r_pl_none_from_pl = PlanMul(r_pl_none, 1)        = {r_pl_none_from_pl:10} -> " + ("ok" if r_orig == r_pl_none_from_pl else "fail"))

    print("\n\ndebug breakpoint")
