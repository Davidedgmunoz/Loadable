# Documentation

## Loadable

This class is the core of this library, consist in a class where you can manage inner
state of the work to fetch/ process data overriding `doSync()` method to indicate it
an usual class would it be a model fetching information from a server
I like to work with MVVM architectures, starting by defining the needed behavior in a protocol
so here its where the `LoadableProtocol` comes into play

```
public protocol Model: LoadableProtocol {
    var items: [Item] { get }
}

// Here we can define another protocol for the Item.
// Why not another loadable that can load its detail on demand?

public protocol Item: LoadableProtocol { 
    var title: String { get }
    var description: String { get }
}
``` 
