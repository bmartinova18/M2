M = ZZ^6
N = directSum {M}
P = directSum {M}
assert( M === N )					    -- changed this test, Jan 15, 2004
assert( N === P )
assert( directSum{M,N} === directSum{M,N} )
-- Local Variables:
-- compile-command: "make direct.okay "
-- End:
