//
//  LoadableProxyProtocol.swift
//  cvmedia
//
//  Created by David Muñoz on 28/04/2022.
//

import Foundation

public protocol LoadableProxyProtocol: LoadableProtocol {
    var loadable: LoadableProtocol! { get }
}
