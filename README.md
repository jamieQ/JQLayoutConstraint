# JQLayoutConstraint

iOS 8 added activation methods onto `NSLayoutConstraint` which optimize the placement of layout constraints into the view heirarchy. This project includes a category on `NSLayoutConstraint` which implements the same API on iOS 7, allowing source compatability between the two SDKs.

#### N.B. This shim uses undocumented APIs.
Internal methods on `UIView`, `NSLayoutConstraint`, and `NSISEngine` are called in order to implement the constraint activation behavior. This should be fairly safe, as the shim is only enabled when running below iOS 8, and Apple will no longer be patching versions of iOS 7. However, it is possible that the iTunes Connect API analysis tool may reject binaries that use these methods.

It may be possible to achieve the same behavior without using making undocumented calls, but it will likely be less efficient.
