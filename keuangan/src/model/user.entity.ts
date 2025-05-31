import { Role } from './role.entity';

// export interface User {
//     userId: number;
//     username: string;
//     password: string;
//     roles: Role[];
// }

import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn, ManyToOne, OneToMany, OneToOne, JoinColumn } from "typeorm";

import { Category } from './category.entity';
import { SavingPlan } from './saving_plan.entity';
import { SavingGoldOwner } from 'src/saving-gold/entities/saving-gold-owner.entity';
import { Transaction } from 'src/transaction/entities/transaction.entity';
import { UserToken } from './user_token.entity';
import { CodeReset } from 'src/users/entities/code_reset.entity';

@Entity()
export class User {
    @PrimaryColumn({ generated: "uuid" }) //it is used to generate primary id, when new data inserted.
    id:string;

    @Column({unique:true}) // It is used to mark a specific class property as a table column
    email: string;
  
    @Column()
    password: string;
    
    @ManyToOne(() => Role, (Role)=> Role.users,{eager:true})
    role: Role

    @OneToMany(() => Transaction, (transaction) => transaction.user,{ nullable:false})
    transactions: Transaction[]

    @OneToMany(() => Category, (category) => category, {nullable:true} )
    categories: Category[]

    @OneToMany(() => SavingPlan, (savingPlan) => savingPlan.user, )
    savingPlans: SavingPlan[]
    
    @OneToMany(() => SavingGoldOwner, (ownGold) => ownGold.user, )
    savingGoldOwner: SavingGoldOwner[]

    @OneToMany(() => UserToken, (data) => data.user, )
    userTokens: UserToken[];

    @OneToOne(()=>CodeReset, codeReset=> codeReset.user)
    @JoinColumn()
    code_reset: CodeReset;

    @Column()
    name: string;

    @CreateDateColumn()
    createdon:Date;
    
    @UpdateDateColumn()
    updatedon:Date;


}