import { Column, CreateDateColumn, DeleteDateColumn,  Entity,  UpdateDateColumn, OneToMany,ManyToOne, PrimaryGeneratedColumn,} from "typeorm";

import { User } from "./user.entity";
import { Transaction } from "src/transaction/entities/transaction.entity";


@Entity()
export class Category {
    @PrimaryGeneratedColumn('increment') //it is used to generate primary id, when new data inserted.
    id: number;

    @Column() // It is used to mark a specific class property as a table column
    category_name: string;

    @OneToMany(() => Transaction, (transaction) => transaction.category, )
    transactions: Transaction[]

    @ManyToOne(() => User, (user)=> user.categories, {nullable:true, })
    user: User;

    @Column('boolean', {default:true})
    canDelete: boolean = true

    @CreateDateColumn()
    createdon:Date;
    
    @UpdateDateColumn()
    updatedon:Date;


}