;; This will restore remove the office apps from the hyper key
;; shortcuts, but the system also tries to run office or open the web
;; site to purchase office when the hyper key is pressed by itself.
;;
;; To fix this, from an Administrator window:
;;    REG ADD HKCU\Software\Classes\ms-officeapp\Shell\Open\Command /t REG_SZ /d rundll32

#^!+W::
Send ^!+W
return

#^!+T::
Send ^!+T
return

#^!+Y::
Send ^!+Y
return

#^!+O::
Send ^!+O
return

#^!+P::
Send ^!+P
return

#^!+D::
Send ^!+D
return

#^!+L::
Send ^!+L
return

#^!+X::
Send ^!+X
return

#^!+N::
Send ^!+N
return

#^!+Space::
Send ^!+Space
return
