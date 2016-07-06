-- Defining the new type Polyhedron
Polyhedron = new Type of PolyhedralObject
Polyhedron.synonym = "convex polyhedron"
globalAssignment Polyhedron

compute#Polyhedron = new MutableHashTable

Polyhedron == Polyhedron := (P1,P2) -> (
   contains(P1, P2) and contains(P2, P1)
)


polyhedron = method()
polyhedron HashTable := inputProperties -> (
   constructTypeFromHash(Polyhedron, inputProperties)
)


     
--   INPUT : 'P'  a Polyhedron
posHull Polyhedron := P -> (
     Mrays := makePrimitiveMatrix vertices(P) | rays(P);
     Mlinspace := linSpace(P);
     posHull(Mrays,Mlinspace))

-- PURPOSE : Computing the Convex Hull of a given set of points and rays
convexHull = method(TypicalValue => Polyhedron)

--   INPUT : 'Mvert'  a Matrix containing the generating points as column vectors
--		 'Mrays'  a Matrix containing the generating rays as column vectors
--  OUTPUT : 'P'  a Polyhedron
-- COMMENT : The description by vertices and rays is stored in P as well as the 
--           description by defining half-spaces and hyperplanes.
convexHull(Matrix, Matrix, Matrix) := (Mvert, Mrays, Mlineality) -> (
   if numgens target Mvert =!= numgens target Mrays then error ("points and rays must lie in the same space");
   if numgens target Mvert =!= numgens target Mlineality then error ("points and lineality generators must lie in the same space");
   result := new HashTable from {
      ambientDimension => numRows Mvert,
      points => Mvert,
      inputRays => Mrays,
      inputLinealityGenerators => Mlineality
   };
   polyhedron result
)

convexHull(Matrix,Matrix) := (Mvert,Mrays) -> (
   r := ring Mvert;
	Mlineality := map(target Mvert,r^0,0);
   convexHull(Mvert, Mrays, Mlineality)
)


--   INPUT : 'M'  a Matrix containing the generating points as column vectors
convexHull Matrix := Mvert -> (
   r := ring Mvert;
	Mrays := map(target Mvert,r^0,0);
	convexHull(Mvert, Mrays)
)


--   INPUT : '(P1,P2)'  two polyhedra
convexHull(Polyhedron,Polyhedron) := (P1,P2) -> (
	-- Checking for input errors
	if ambDim(P1) =!= ambDim(P2) then error("Polyhedra must lie in the same ambient space");
   C1 := getProperty(P1, underlyingCone);
   C2 := getProperty(P2, underlyingCone);
   result := new HashTable from {
      ambientDimension => ambDim P1,
      underlyingCone => posHull(C1, C2)
   };
   polyhedron result;
)
   
--   INPUT : 'L',   a list of Cones, Polyhedra, vertices given by M, 
--     	    	    and (vertices,rays) given by '(V,R)'
convexHull List := L -> (
   polyhedra := apply(L,
      l -> (
         if not instance(l, Polyhedron) then convexHull l
         else l
      )
   );
   cones := apply(polyhedra, p -> getProperty(p, underlyingCone));
   underLyingResult := posHull(cones);
   result := new HashTable from {
      underlyingCone => underLyingResult
   };
   polyhedron result
)

polyhedron Cone := C -> (
   n := ambDim C;
   rayData := getSufficientRayData C;
   r := ring rayData#0;
   vertex := map(ZZ^n, ZZ^1, 0);
   convexHull(vertex, rayData#0, rayData#1)
)

