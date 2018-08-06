import Foundation

public func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}

public func executeProcedure(for description:String, procedure: () -> Void){
    print("Procedure executed for:", description)
    procedure()
}
