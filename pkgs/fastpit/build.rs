fn main() {
    capnpc::CompilerCommand::new()
        .src_prefix("data")
        .file("data/corpus.capnp")
        .run()
        .expect("capnp schema compilation failed");
}
