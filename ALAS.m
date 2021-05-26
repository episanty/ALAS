(* ::Package:: *)

(************************************************************************)
(* This file was generated automatically by the Mathematica front end.  *)
(* It contains Initialization cells from a Notebook file, which         *)
(* typically will have the same name as this file except ending in      *)
(* ".nb" instead of ".m".                                               *)
(*                                                                      *)
(* This file is intended to be loaded into the Mathematica kernel using *)
(* the package loading commands Get or Needs.  Doing so is equivalent   *)
(* to using the Evaluate Initialization Cells menu command in the front *)
(* end.                                                                 *)
(*                                                                      *)
(* DO NOT EDIT THIS FILE.  This entire file is regenerated              *)
(* automatically each time the parent Notebook file is saved in the     *)
(* Mathematica front end.  Any changes you make to this file will be    *)
(* overwritten.                                                         *)
(************************************************************************)



(* ::Input::Initialization:: *)
(*
This is the ALAS package, \[Copyright] Emilio Pisanty (2021). For the notebook that generated this package file and additional documentaion, see https://github.com/episanty/ALAS.
*)


(* ::Input::Initialization:: *)
BeginPackage["ALAS`"];


(* ::Input::Initialization:: *)
$ALASVersion::usage="$ALASVersion prints the current version of the ALAS package in use and its timestamp.";
$ALASTimestamp::usage="$ALASTimestamp prints the timestamp of the current version of the ALAS package.";


(* ::Input::Initialization:: *)
Begin["`Private`"];
$ALASVersion:="ALAS v0.1, "<>$ALASTimestamp;


(* ::Input::Initialization:: *)
$ALASTimestamp="Wed 26 May 2021 17:36:37";
End[];


(* ::Input::Initialization:: *)
$ALASDirectory::usage="$ALASDirectory is the directory where the current ALAS package instance is located.";


(* ::Input::Initialization:: *)
Begin["`Private`"];
With[{softLinkTestString=StringSplit[StringJoin[ReadList["! ls -la "<>StringReplace[$InputFileName,{" "->"\\ "}],String]]," -> "]},
If[Length[softLinkTestString]>1,(*Testing in case $InputFileName is a soft link to the actual directory.*)
$ALASDirectory=StringReplace[DirectoryName[softLinkTestString[[2]]],{" "->"\\ "}],
$ALASDirectory=StringReplace[DirectoryName[$InputFileName],{" "->"\\ "}];
]];
End[];


(* ::Input::Initialization:: *)
$ALASCommit::usage="$ALASCommit returns the git commit log at the location of the ALAS package if there is one.";
$ALASCommit::OS="$ALASCommit has only been tested on Linux.";


(* ::Input::Initialization:: *)
Begin["`Private`"];
$ALASCommit:=(If[$OperatingSystem!="Unix",Message[$ALASCommit::OS]];
StringJoin[Riffle[ReadList["!cd "<>$ALASDirectory<>" && git log -1",String],{"\n"}]]);
End[];


(* ::Input::Initialization:: *)
$ASDLevelsBaseURL="https://physics.nist.gov/cgi-bin/ASD/energy1.pl";
$ASDLinesBaseURL="https://physics.nist.gov/cgi-bin/ASD/lines1.pl";


(* ::Input::Initialization:: *)
ASDOptionHandler[_][value_]:=ReplaceAll[value,{True->"on",False->""}]
ASDOptionHandler["unc_out"|"splitting"][value_]:=ReplaceAll[value,{True->"1",False->""}]
ASDOptionHandler["units"][value_]:=ReplaceAll[value,{"cm-1"->"0","eV"->"1","Rydberg"->"2"}]
ASDOptionHandler["format"][value_]:=ReplaceAll[value,{"HTML"->"0","ASCII"->"1","CSV"->"2","Tab-delimited"->"3"}]


(* ::Input::Initialization:: *)
Options[ASDLevelQuery]={
"submit"->"Retrieve+Data",
"units"->"eV",
"format"->"CSV",
"multiplet_ordered"->"0",(*0 for 'Term ordered', 1 for 'Energy ordered'*)
(*Principal configuration*)"conf_out"->True,
(*Principal term*)"term_out"->True,
(*Level, i.e. energy*)"level_out"->True,
(*Uncertainty*)"unc_out"->True,
(*J*)"j_out"->True,
(*g*)"g_out"->True,
(*Land\[EAcute]-g*)"lande_out"->True,
(*Leading percentages*)"perc_out"->True,
(*Bibliographic references*)"biblio"->True,
(*Level splitting*)"splitting"->False
};


(* ::Input::Initialization:: *)
ASDLevelQuery[species_,opts:OptionsPattern[]]:=ASDLevelQuery[species,0,opts]
ASDLevelQuery[species_,charge_,OptionsPattern[]]:=Flatten[Join[
{"spectrum"->FormatSpecies[species,charge]},
Table[
ReplaceAll[
option->ASDOptionHandler[option][OptionValue[option]]
,{Rule[_,""]->{}}](*remove options set to False, which have empty strings at the end here*)
,{option,Options[ASDLevelQuery][[All,1]]}]
]]

(*ASDLevelQuery["B",0]
ASDLevelQuery["B",0,"units"\[Rule]"cm-1","biblio"\[Rule]False]*)


(* ::Input::Initialization:: *)
$ALASUserAgent="Atomic Levels And Spectra package, https://github.com/episanty/ALAS, version "<>$ALASVersion<>", running using the "<>("user-agent"/.HTTPRequest[""]["Headers"])<>" on Mathematica "<>$Version;


(* ::Input::Initialization:: *)
Options[ASDLevelRequest]=Options[ASDLevelQuery];

ASDLevelRequest[species_,opts:OptionsPattern[]]:=ASDLevelRequest[species,0,opts]
ASDLevelRequest[species_,charge_,OptionsPattern[]]:=HTTPRequest[URL[$ASDLevelsBaseURL],
<|
"Query"->ASDLevelQuery[species,charge],
"UserAgent"->$ALASUserAgent
|>
]

(*ASDLevelRequest["B",0]*)


(* ::Input::Initialization:: *)
FormatSpecies[{species_,charge_}]:=FormatSpecies[species,charge]
FormatSpecies[species_]:=FormatSpecies[species,0]
FormatSpecies[species_,charge_]:=StringJoin[FormatSpeciesName[species],"+",ToString[charge]]

FormatSpeciesName[species_]:=ElementData[species,"Abbreviation"]


(* ::Input::Initialization:: *)
SubmitASDQuery[query_]:=SubmitASDQuery[query]=URLRead[query]


(* ::Input::Initialization:: *)
TrimASDRecordStrings[item_]:=If[StringQ[item],StringTrim[item,"=\""|"\""],item]


(* ::Input::Initialization:: *)
ParseASDQueryResponse[response_]:=Block[{ContentType,RawTable},
ContentType=StringSplit[
Association[response["Headers"]]["content-type"]
," "][[1]];

If[ContentType=="text/html;",Return[{}]];
(*Errors are returned as HTML*)

RawTable=ImportString[response["Body"],"CSV"];

Map[
Association[Thread[RawTable[[1]]->(TrimASDRecordStrings/@#)]]&,
RawTable[[2;;]]
]

]

(*ParseASDQueryResponse[response1]\[LeftDoubleBracket]1;;10\[RightDoubleBracket]*)
(*ParseASDQueryResponse[response2]*)


(* ::Input::Initialization:: *)
ParseASDRecord[assoc_]:=Association[{
"ConfigurationString"->assoc["Configuration"],
"TermString"->assoc["Term"],
"J"->ToExpression[assoc["J"]],
"g"->ToExpression[assoc["g"]],
"Energy"->Quantity[ToExpression[assoc["Level (eV)"]<>"`"],"Electronvolts"],
"EnergyUncertainty"->Quantity[ToExpression[assoc["Uncertainty (eV)"]<>"`"],"Electronvolts"],
(*"LeadingPercentages"\[Rule]assoc["Leading percentages"],*)
"Reference"->assoc["Reference"]
}]

(*ParseASDRecord[ParseASDQueryResponse[response1]\[LeftDoubleBracket]2\[RightDoubleBracket]]*)
(*ParseASDRecord[ParseASDQueryResponse[response1]\[LeftDoubleBracket]2\[RightDoubleBracket]]//InputForm*)


(* ::Input::Initialization:: *)
EndPackage[];


(* ::Input::Initialization:: *)
DistributeDefinitions["ALAS`"];


(* ::Input::Initialization:: *)
$spectroscopicNotationSeries=Join[{"s","p","d","f"},CharacterRange["g","z"]];
$SpectroscopicNotationSeries=ToUpperCase/@$shellNames;



