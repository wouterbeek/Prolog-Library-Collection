:- module(
  rfc6265,
  [
    'set-cookie'//1 % -Cookie:compound
  ]
).

/** <module> RFC 6265: HTTP State Management Mechanism

@author Wouter Beek
@compat RFC 6265
@see https://tools.ietf.org/html/rfc6265
@version 2015/12, 2016/12
*/

:- use_module(library(dcg/dcg_ext)).
:- use_module(library(dcg/rfc2234), [
     'ALPHA'//1, % ?Code:code
     'CHAR'//1, % ?Code:code
     'CR'//0,
     'CRLF'//0,
     'CTL'//1, % ?Code:code
     'DIGIT'//1, % ?Weight:between(0,9)
     'DQUOTE'//0,
     'HEXDIG'//1, % ?Weight:between(0,15)
     'HTAB'//0,
     'LF'//0,
     'OCTET'//1, % ?Code:code
     'SP'//0,
     'VCHAR'//1, % ?Code:code
     'WSP'//0
   ]).
:- use_module(library(dict_ext)).
:- use_module(library(http/rfc1034)).
:- use_module(library(http/rfc2616)).
:- use_module(library(http/http11)).





%! 'cookie-av'(-Param:pair(atom))// is det.
%
% ```abnf
% cookie-av = expires-av
%           | max-age-av
%           | domain-av
%           | path-av
%           | secure-av
%           | httponly-av
%           | extension-av
% ```

'cookie-av'(expires-Lex) -->
  'expires-av'(Lex), !.
'cookie-av'('max-age'-MaxAge) -->
  'max-age-av'(MaxAge), !.
'cookie-av'(domain-Domain) -->
  'domain-av'(Domain), !.
'cookie-av'(path-Path) -->
  'path-av'(Path), !.
'cookie-av'(secure-true) -->
  'secure-av', !.
'cookie-av'(httponly-true) -->
  'httponly-av', !.
'cookie-av'(extension-Ext) -->
  'extension-av'(Ext).



%! 'cookie-pair'(-Param)// is det.
%
% ```abnf
% cookie-pair = cookie-name "=" cookie-value
% ```

'cookie-pair'(Key-Val) -->
  'cookie-name'(Key),
  "=",
  'cookie-value'(Val).



%! 'cookie-name'(-Name:atom)// is det.
%
% ```abnf
% cookie-name = token
% ```

'cookie-name'(Name) -->
  token(Name).



%! 'cookie-octet'(?Code:code)// is det.
%
% ```abnf
% cookie-octet = %x21 | %x23-2B | %x2D-3A | %x3C-5B | %x5D-7E
%              ; US-ASCII characters excluding CTLs,
%              ; whitespace DQUOTE, comma, semicolon,
%              ; and backslash
% ```

'cookie-octet'(0x21) -->
  [0x21], !.
'cookie-octet'(C) -->
  [C],
  (   {between(0x23, 0x2B, C)}, !
  ;   {between(0x2D, 0x3A, C)}, !
  ;   {between(0x3C, 0x5B, C)}, !
  ;   {between(0x5D, 0x7E, C)}
  ).



%! 'cookie-value'(-Val:atom)// is det.
%
% ```abnf
% cookie-value = *cookie-octet
%              | ( DQUOTE *cookie-octet DQUOTE )
% ```

'cookie-value'(Val) -->
  'DQUOTE', !,
  dcg_atom(cookie_value_codes, Val),
  'DQUOTE'.
'cookie-value'(Val) -->
  dcg_atom(cookie_value_codes, Val).

cookie_value_codes(Cs) -->
  *('cookie-octet', Cs), !.



%! 'domain-av'(-Domain:list(atom))// is det.
%
% ```abnf
% domain-av = "Domain=" domain-value
% ```

'domain-av'(Domain) -->
  atom_ci('Domain'),
  "=",
  'domain-value'(Domain).



%! 'domain-value'(-Subdomain:list(atom))// is det.
%
% ```abnf
% domain-value = <subdomain>   ; defined in [RFC1034], Section 3.5, as
%                              ; enhanced by [RFC1123], Section 2.1
% ```

'domain-value'(Domain) -->
  subdomain(Domain).



%! 'expires-av'(-Lex:atom)// is det.
%
% ```abnf
% expires-av = "Expires=" sane-cookie-date
% ```

'expires-av'(Lex) -->
  atom_ci('Expires'),
  "=",
  'sane-cookie-date'(Lex).



%! 'extension-av'(-Ext:atom)// is det.
%
% ```abnf
% extension-av = <any CHAR except CTLs or ";">
% ```

'extension-av'(Ext) -->
  word(Ext).



%! 'httponly-av'// is det.
%
% ```abnf
% httponly-av = "HttpOnly"
% ```

'httponly-av' -->
  atom_ci('HttpOnly').



%! 'max-age-av'(-MaxAge:nonneg)// is det.
%
% ```abnf
% max-age-av = "Max-Age=" non-zero-digit *DIGIT
%            ; In practice, both expires-av and max-age-av
%            ; are limited to dates representable by the user agent.
% ```

'max-age-av'(MaxAge) -->
  atom_ci('Max-Age'),
  "=",
  'non-zero-digit'(H),
  *(digit, T), !,
  {pos_sum([H|T], MaxAge)}.



%! 'non-zero-digit'(-Digit:between(1,9))// is det.
%
% ```abnf
% non-zero-digit = %x31-39   ; digits 1 through 9
% ```

'non-zero-digit'(1) --> "1", !.
'non-zero-digit'(2) --> "2", !.
'non-zero-digit'(3) --> "3", !.
'non-zero-digit'(4) --> "4", !.
'non-zero-digit'(5) --> "5", !.
'non-zero-digit'(6) --> "6", !.
'non-zero-digit'(7) --> "7", !.
'non-zero-digit'(8) --> "8", !.
'non-zero-digit'(9) --> "9".



%! 'path-av'(-Path:atom)// is det.
%
% ```abnf
% path-av = "Path=" path-value
% ```

'path-av'(Path) -->
  atom_ci('Path'),
  "=",
  'path-value'(Path).



%! 'path-value'(-Path:atom)// is det.
%
% ```abnf
% path-value = <any CHAR except CTLs or ";">
% ```

'path-value'(Path) -->
  word(Path).



%! 'sane-cookie-date'(-Lex:atom)// is det.
%
% ```abnf
% sane-cookie-date = <rfc1123-date, defined in [RFC2616], Section 3.3.1>
% ```

'sane-cookie-date'(Lex) -->
  'rfc1123-date'(Lex).



%! 'secure-av'// is det.
%
% ```abnf
% secure-av = "Secure"
% ```

'secure-av' -->
  atom_ci('Secure').



%! 'set-cookie'(-Cookie:compound)// is det.
%
% ```abnf
% set-cookie-header = "Set-Cookie:" SP set-cookie-string
% ```

'set-cookie'(Cookie) -->
  'set-cookie-string'(Cookie).



%! 'set-cookie-string'(-Params:list(pair(atom)))// is det.
%
% ```abnf
% set-cookie-string = cookie-pair *( ";" SP cookie-av )
% ```

'set-cookie-string'([H|T]) -->
  'cookie-pair'(H),
  *(sep_cookie_av, T), !.

sep_cookie_av(Param) -->
  ";",
  'SP',
  'cookie-av'(Param).





% HELPERS %

word(Word) -->
  dcg_atom(word_codes, Word).

word_codes(Cs) -->
  *(word_code, Cs), !.

word_code(C) -->
  'CHAR'(C),
  {
    \+ 'CTL'(C, _, _),
    C \= 0';
  }.
