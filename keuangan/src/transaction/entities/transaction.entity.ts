import { ColumnNumericTransformer } from "src/config/database/column_numeric_transformer";
import { Category } from "src/model/category.entity";
import { User } from "src/model/user.entity";
import { Column, CreateDateColumn,  Entity,  UpdateDateColumn, ManyToOne, PrimaryGeneratedColumn } from "typeorm";



@Entity()
export class Transaction {
    @PrimaryGeneratedColumn('increment') //it is used to generate primary id, when new data inserted.
    id: number;

    @Column() // It is used to mark a specific class property as a table column
    name: string;

    @Column({type:'text', nullable:true})
    detail: string | null;

    @Column({type:'decimal', precision:20, scale:2, transformer: new ColumnNumericTransformer()})
    harga: number;
    public myHargaColumn: number;

    @Column({type:'enum', enum:['debit', 'credit'], default:'debit'})
    debcre: string;

    // @Column({type:'enum', enum:['primer', 'tersier'], default:'primer'})
    // kategori2: string;


    @Column({type:'date'})
    tanggal_transaksi: Date;

    @ManyToOne(() => Category, (category) => category.transactions, {eager:true})
    category: Category;
    
    @ManyToOne(() => User, (user)=> user.transactions)
    user: User;
    
    @CreateDateColumn()
    createdon:Date;
    
    @UpdateDateColumn()
    updatedon:Date;


}