#import "@preview/arkheion:0.1.0": arkheion, arkheion-appendices
#import "@preview/unify:0.6.0": num,qty,numrange,qtyrange
#import "@preview/pinit:0.1.4": *
#import "@preview/physica:0.9.3": *

#let pinit-highlight-equation-from(height: 2em, pos: bottom, fill: rgb(0, 180, 255), dx:0em, highlight-pins, point-pin, body) = {
  pinit-highlight(..highlight-pins, dy: -0.6em, fill: rgb(..fill.components().slice(0, -1), 40))
  pinit-point-from(
    fill: fill, pin-dx: -0.6em+dx, pin-dy: if pos == bottom { 0.8em } else { -0.6em }, body-dx: 0pt, body-dy: if pos == bottom { -1.7em } else { -1.6em }, offset-dx: -0.6em+dx, offset-dy: if pos == bottom { 0.8em + height } else { -0.6em - height },
    point-pin,
    rect(
      inset: 0.5em,
      stroke: (bottom: 0.12em + fill),
      {
        set text(fill: fill)
        body
      }
    )
  )
}

#show: arkheion.with(
  title: "A Gentle Introduction to the Phase Screen Model",
  authors: (
    (name: "Rubem Vasconcelos Pacelli", email: "rubem.engenharia@gmail.com", affiliation: "Department of Teleinformatics", orcid: "0000-0001-5933-8565"),
    // (name: "Author 2", email: "user@domain.com", affiliation: "Company"),
  ),
  // Insert your abstract after the colon, wrapped in brackets.
  // Example: `abstract: [This is my abstract...]`
  abstract: [
    This note provides a basic introduction to the two-dimensional two-component power-law phase screen model for equatorial regions, developed by Charles L. Rino, Charles S. Carrano, Y.T. Jade Morton, _et. al._. The state of the art of the model is quite complex and requires deep knowledge in the field of electromagnetic wave propagation and vector calculus. On the one hand, students who have such a background and are interested in a down-top learning approach are encouraged to read the author's book @rinoTheoryScintillationApplications2011. On the other hand, students with a mild background in these fields or who are interested in a top-down learning and implementation-focused approach may find this note interesting. In the top-down approach, we start with the simplifications and assumptions that lead to the phase screen model and then go deeper into the theoretical details of electromagnetic propagation as much as necessary. Moreover, we take special care about how the theoretical concepts are implemented in code. As references, we will use the various versions of the phase screen model implemented by the team to understand how the theory is implemented in practice. Most of the code is implemented in Matlab. However, some knowledge of GNSS signal processing and stochastic processing is assumed.
  ],
  // keywords: ("First keyword", "Second keyword", "etc."),
  date: "May 16, 2023",
)

= GNSS measurement models

Let us start with the most fundamental concept in GNSS: the time that the satellite-transmited signal takes to reach the receiver/user, $tau$. We first model the code and carrier phase pseudorange measurements are modelled separately.

== Code phase pseudorange measurement

Considering that the GNSS signals are propagating at the speed of light #cite(<teunissenSpringerHandbookGlobal2017>, supplement: "p. 5"), we have:

#pagebreak()
$ #pin("rho1")rho#pin("rho2") (t) = #pin("c1")c#pin("c2") [ #pin("t_u1")t_u (t)#pin("t_u2") - #pin("t^s1")t^s (t - tau)#pin("t^s2") ] $

#pinit-highlight-equation-from(("t^s1", "t^s2"), "t^s1", height: 2em, pos: bottom, fill: blue, dx: 1em)[
  #block(width: 20em)[
    The emission time (in seconds), which is observed with respect to the satellite clock.
  ]
]

#pinit-highlight-equation-from(("t_u1", "t_u2"), "t_u1", height: 5em, pos: bottom, fill: blue, dx: 1em)[
  #block(width: 20em)[
    The arrival time (in seconds), which is observed with respect to the receiver clock.
  ]
]

#pinit-highlight-equation-from(("c1", "c2"), "c1", height: 8em, pos: bottom, fill: blue, dx: 1em)[
  #block(width: 20em)[
    the speed of light, #qty("300e6", "m / s").
  ]
]

#pinit-highlight-equation-from(("rho1", "rho2"), "rho1", height: 10em, pos: bottom, fill: blue, dx: 0.8em)[
  #block(width: 25em)[
    the pseudorange (in meters): The apparent distance from the satellite to the receiver. It is so called since the travelling time is biased by many impairing factors, such as receiver/satellite clock bias, tropospheric/ionospheric delay, hardware bias, etc.
  ]
]

#v(18em)

By putting the time scales in terms of the reference timing, defined and broadcasted by the control segment, we have #cite(<misraGlobalPositioningSystem2006>, supplement: "p. 148"):

$ t_u (t) = t + #pin("delta t_u1")delta t_u (t)#pin("delta t_u2") $

#pinit-highlight-equation-from(("delta t_u1", "delta t_u2"), "delta t_u1", height: 2em, pos: bottom, fill: blue, dx: 1em)[
  Receiver clock error
]

#v(2em)

and

$ t^s (t - tau) = (t - tau) + #pin("delta t^s1")delta t^s (t)#pin("delta t^s2") $

#pinit-highlight-equation-from(("delta t^s1", "delta t^s2"), "delta t^s1", height: 2em, pos: bottom, fill: blue, dx: 1em)[
  Satellite clock error
]

#v(2em)

Therefore:

$
rho (t) & = c tau + c [delta t_u (t) - delta t^s (t - tau)] \
        & = c tau + c delta t_u^s (tau),
$

- $delta t_u^s (tau) #sym.eq.delta delta t_u (t) - delta t^s (t - tau)$: the net clock error bias with regard to the reference timing.

The main idea is to model the interference sources that impair $c tau$. The theory of scintillation generally assumes the absence of noise, clock error bias (so $delta t_u^s (tau) = 0$), and other error sources but the ionosphere @rinoCompactMultifrequencyGNSS2018. Therefore,

$
#rect[#math.equation(block: true, numbering: none)[$c tau = #pin("r1")r#pin("r2") + #pin("I1")I#pin("I2") + lambda_c/(2pi) #pin("phi.alt_s1")phi.alt_s (t)#pin("phi.alt_s2")$]]
$

#pinit-highlight-equation-from(("r1", "r2"), "r1", height: 8em, pos: bottom, fill: blue, dx: 1em)[
  in meters: the true range
]

#pinit-highlight-equation-from(("I1", "I2"), "I1", height: 6em, pos: bottom, fill: blue, dx: 1em)[
  in meters: ionosphere delay error model
]

#pinit-highlight-equation-from(("phi.alt_s1", "phi.alt_s2"), "phi.alt_s1", height: 2.5em, pos: bottom, fill: blue, dx: 1em)[
  #block(width: 15em)[
    in rad: scintillation phase. The factor $lambda_c/(2pi)$ converts rad to meters.
  ]
]

#v(8em)

where $lambda_c = c slash f_c$ is the wavelength (in meters) and $f_c$ is the carrier frequency (in Hz). The ionospheric delay model is given by #cite(<misraGlobalPositioningSystem2006>, supplement: "p. 163")

$ I = (40.3 T E C)/ f^2 $

Where $T E C$ is the total content electron, defined as the number of electrons in a tube of $#qty("1", "meter squared")$ cross-section from the receiver to the satellite and measured in 1 TECU = $10^16 e^- slash m^2$.

// - $I = (40.3 T E C)/ f^2$ (in meters): models the ionosphere delay #cite(<misraGlobalPositioningSystem2006>, supplement: "p. 163");
// - $T E C$ (in TECU), total content electron: the number of electrons in a tube of $#qty("1", "meter squared")$ cross-section from the receiver to the satellite, measured in TEC units (TECU), where 1 TECU = $10^16 e^- slash m^2$.
// - $phi.alt_s (t)$ (in rad): scintillation phase. The factor $lambda_c/(2pi)$ converts rad to meters.
// - $r$ (in meters), the true range.
// - $lambda_c = c/f_c$ (in meters): the wavelength.
// - $f_c$ (in Hz): the carrier frequency.

== Carrier phase measurement

Likewise, one can measure the travelling time considering the carrier phase, that is, #cite(<misraGlobalPositioningSystem2006>, supplement: "p. 153")

$ phi.alt (t) = #pin("phi.alt_1")phi.alt_u (t)#pin("phi.alt_2") - #pin("phi.alt^s1")phi.alt^s (t - tau)#pin("phi.alt^s2") + 2 pi #pin("N1")N#pin("N2") $<eq:1>

#pinit-highlight-equation-from(("phi.alt_1", "phi.alt_2"), "phi.alt_1", height: 10em, pos: bottom, fill: blue, dx: 1em)[
  #block(width: 20em)[in rad: receiver carrier phase generated by the local NCO (numerically-controlled oscillator) at the reception time (with regard to the receiver timing).]
]

#pinit-highlight-equation-from(("phi.alt^s1", "phi.alt^s2"), "phi.alt^s1", height: 5em, pos: bottom, fill: blue, dx: 1em)[
  #block(width: 20em)[in rad: satellite carrier phase at the emission time (with regard to the satellite timing)]
]

#pinit-highlight-equation-from(("N1", "N2"), "N1", height: 2em, pos: bottom, fill: blue, dx: 1em)[
  Dimensionless: integer ambiguity
]

#v(14em)

By considering a stable oscillator, one can assume that #cite(<misraGlobalPositioningSystem2006>, supplement: "p. 153")

$ phi.alt_u (t) - phi.alt^s (t - tau) approx 2 pi f tau. $<eq:2>

Similarly to $c tau$, we should model the error sources that impair $f tau$. By considering only the ionosphere effects and ignoring the clock bias, we have that

$ f tau = (r - I)/lambda_c + (phi.alt_s (t))/(2pi), $<eq:3>

where the minus in the ionospheric interference is due to the code-carrier divergence #cite(<misraGlobalPositioningSystem2006>, supplement: [p. 153 _et seq._]). Note that, since the left-hand side of the equation is in the number of cycles (adimensional), the modelling error in the right-hand side needs to be normalized by the carrier wavelength, $lambda_c$ (in meters), and $2pi$.

Substituting @eq:3 and @eq:2 into @eq:1 leads to

$
phi.alt (t) = (2pi)/lambda_c (r - I) + phi.alt_s (t) + 2 pi N
$

By converting from rad to meters, we have

$
#rect[#math.equation(block: true, numbering: none)[$lambda_c/(2pi) phi.alt (t) = r - I + lambda_c/(2pi) phi.alt_s (t) + lambda_c N$]]
$

== Scintillation signal

By considering only the satellite-user range variation and the ionospheric effects, the received signal power can be modelled as @rinoCompactMultifrequencyGNSS2018

$ #pin("I1")I (t)#pin("I2") = #pin("P1")P (t)#pin("P4") #pin("h1")|h (t)|#pin("h2")^2 $

#pinit-highlight-equation-from(("I1", "I2"), "I1", height: 9em, pos: bottom, fill: blue, dx: 1.5em)[
  Received signal power
]

#pinit-highlight-equation-from(("P1", "P4"), "P1", height: 4em, pos: bottom, fill: blue, dx: 1.5em)[
  #block(width: 20em)[
    LOS (line-of-sight) signal power variation. The path loss and antenna gain are also taken into account.
  ]
]

#pinit-highlight-equation-from(("h1", "h2"), "h1", height: 2em, pos: bottom, fill: blue, dx: 1.5em)[
  Scintillation amplitude.
]

#v(9em)

Finally, the scintillation signal can be modelled as

$ h (t) = |h (t)| e^(j phi.alt_s (t)) $

= Phase screen model

// #align(center, block(
//   fill: luma(230),
//   inset: 8pt,
//   radius: 4pt,
// )[The phase screen model defined a complex field, $psi$, from which $h(t)$ can be derived.])

Let us assume that
- The phase screen model is used to model equatorial scintillation, which is caused by irregularities that are highly elongated along the geomagnetic field lines @jiaoScintillationSimulationEquatorial2017;
- The electromagnetic wave is simplified to a plane wave propagating through the phase screen realization, which is defined in a two-dimensional space @jiaoScintillationSimulationEquatorial2017:
  - $x$ (in meters): distance from the phase screen in the propagation direction @jiaoScintillationSimulationEquatorial2017, @xuTwoparameterMultifrequencyGPS2020;
  - $y$ (in meters): geometric eastward direction @jiaoScintillationSimulationEquatorial2017, i.e., the field-aligned direction @xuTwoparameterMultifrequencyGPS2020. It is assumed that this direction is transverse to $x$ #cite(<jiaoLowlatitudeIonosphericScintillation2017>, supplement: "p. 52");
== Phase screen realization
  
Let $psi (x, y)$ be the complex field representing #text(fill: blue)[principal] (i.e., scalar) component of the electromagnetic wave @rinoCompactMultifrequencyGNSS2018. Considering that the propagation of the electromagnetic wave in the Earth's ionosphere is transparent for the GNSS frequency band, one can state that it is governed parabolic wave equation (PWE). Once the scalar form of the PWE is sufficient to characterize the complex modulation impairing the plane wave @rinoCompactMultifrequencyGNSS2018, we have that:

#v(2.5cm)

$
#rect[#math.equation(block: true, numbering: none)[$(partial #pin(7)psi (x, y)#pin(8))/(#pin(3)partial x#pin(4)) = #pin(1)Theta_(rho_f) psi (x, y)#pin(2) + #pin(5)j #pin(9)k#pin(10) #pin(11)Delta n (x,y)#pin(12) psi (x, y)#pin(6)$]]
$

#pinit-highlight-equation-from((1, 2), 2, height: 4em, pos: top, fill: blue, dx: -2em)[
  Free-space propagation @rinoNewGNSSScintillation2017
]

#pinit-highlight-equation-from((3, 4), 4, height: 5em, pos: bottom, fill: blue)[
  Differentiate on the propagation axis.
]

#pinit-highlight-equation-from((5, 6), 5, height: 2em, pos: top, fill: blue, dx: 2em)[
  Interaction with the propagation medium @rinoNewGNSSScintillation2017
]

#pinit-highlight-equation-from((7, 8), 7, height: 4.8em, pos: top, fill: blue, dx: 2em)[
  Complex field
]

#pinit-highlight-equation-from((9, 10), 9, height: 4em, pos: bottom, fill: red, dx: 0.8em)[
  Carrier wavenumber
]

#pinit-highlight-equation-from((11, 12), 11, height: 2em, pos: bottom, fill: red, dx: 2em)[
  Local refractive index in the point $(x, y)$
]

#v(5em)

The free-space propagation term is given by @rinoNewGNSSScintillation2017

#v(5em)

$ Theta_(rho_f) psi (x, y) = integral #pin("Psi (x, q_y)1")Psi (x, q_y)#pin("Psi (x, q_y)2") e^(-j ((q_y #pin("rho_F1")rho_F#pin("rho_F2"))^2)/2) e^(j y q_y) dd(#pin("q_y1")q_y#pin("q_y2"))/(2pi) $<eq:Theta_rho_f_continuous>

#pinit-highlight-equation-from(("Psi (x, q_y)1", "Psi (x, q_y)2"), "Psi (x, q_y)1", height: 2em, pos: bottom, fill: blue, dx: 1em)[
  #block(width: 20em)[
    Fourier transformation of the complex field, $phi (x, y)$ in $y$
  ]
]

#pinit-highlight-equation-from(("q_y1", "q_y2"), "q_y1", height: 2em, pos: top, fill: blue, dx: 1em)[
  #block(width: 10em)[
    The wavenumber on the direction $y$ @jiaoScintillationSimulationEquatorial2017
  ]
]

#pinit-highlight-equation-from(("rho_F1", "rho_F2"), "rho_F1", height: 4em, pos: top, fill: blue, dx: 1em)[
    Fresnel scale.
]

#v(4em)


where

$ rho_F = sqrt(x slash k) $

and

$ Psi (x, q_y) = cal(F)_y {psi (x, y)} = integral psi (x, y) e^(-j q_y y) dd(y) $<eq:Psi_continuous>

#text(fill: red)[In the absence of diffraction], the complex field defined by PWE has an analytical solution, given by #cite(<rinoCompactMultifrequencyGNSS2018>, supplement: "Equation (11)")

$ psi (x + Delta x, y) = psi (x, y) "exp"{j #pin("refractive_phase_contribution1")k integral_x^(x+Delta x) Delta n (eta, y) dd(eta)#pin("refractive_phase_contribution2")} $

#pinit-highlight-equation-from(("refractive_phase_contribution1", "refractive_phase_contribution2"), "refractive_phase_contribution1", height: 2em, pos: bottom, fill: blue, dx: 1em)[
  #block(width: 20em)[
    The phase contribution due to the refractive part in the point $y$ after the wave has passed $Delta x$ through the phase screen
  ]
]

// By discretizing @eq:Psi_continuous and @eq:Theta_rho_f_continuous, we have

// $ Psi (x, n Delta q) = "DFT"_y {psi (x, y)} = sum_(m = 0)^(N-1) psi (x, y) e^(-j q_y y) dd(y) $<eq:Psi_discrete>


#bibliography("refs.bib")

// #show: arkheion-appendices
// =

// == Appendix section

// #lorem(100)